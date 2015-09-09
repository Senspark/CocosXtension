//
//  TestParseScene.cpp
//  HelloPlugins
//
//  Created by Duc Nguyen on 8/14/15.
//
//

#include "TestParseScene.h"
#include "ProtocolBaaS.h"
#include "json/rapidjson.h"
#include "json/stringbuffer.h"
#include "json/writer.h"

USING_NS_CC;
USING_NS_CC_EXT;
USING_NS_SENSPARK_PLUGIN_BAAS;

using namespace cocos2d::plugin;
using namespace rapidjson;

enum {
    TAG_PF_SIGNUP = 1,
    TAG_PF_LOGIN,
    TAG_PF_LOGOUT,
    TAG_PF_WRITE_OBJECT,
    TAG_PF_READ_OBJECT,
    TAG_PF_UPDATE_OBJECT,
};

struct PFEventMenuItem {
    const char* name;
    int tag;
};

static PFEventMenuItem s_PFMenuItem[] =
{   {"signup", TAG_PF_SIGNUP},
    {"login", TAG_PF_LOGIN},
    {"logout", TAG_PF_LOGOUT},
    {"write object", TAG_PF_WRITE_OBJECT},
    {"read object", TAG_PF_READ_OBJECT},
    {"update object", TAG_PF_READ_OBJECT},
    {nullptr, 0},
};

Scene* TestParseBaaS::scene() {
    // 'scene' is an autorelease object
    Scene *scene = Scene::create();
    
    // 'layer' is an autorelease object
    auto *layer = TestParseBaaS::create();
    
    // add layer as a child to scene
    scene->addChild(layer);
    
    // return the scene
    return scene;
}

bool TestParseBaaS::init() {
    //////////////////////////////
    // 1. super init first
    if ( !ListLayer::init() )
    {
        return false;
    }
    
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Point origin = Director::getInstance()->getVisibleOrigin();
    Point posMid = Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2);
    Point posBR = Point(origin.x + visibleSize.width, origin.y);
    
    
    //2.Add Title
    auto title = Label::createWithSystemFont("Test Parse BaaS", "Arial", 32);
    title->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height - 64);
    addChild(title);
    
//    std::string sdkVersion = "SDK Version is: 1.4.1";
//    auto subTitle = Label::createWithSystemFont(sdkVersion.c_str(), "Arial", 18);
//    subTitle->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height - 88);
//    addChild(subTitle);
    
    _testListView->setViewSize(Size(visibleSize.width / 3, visibleSize.height / 2));
    _testListView->setPosition(origin + Size(0, visibleSize.height / 4));
    
    for (int i = 0; s_PFMenuItem[i].name != nullptr; i++) {
        addTest(s_PFMenuItem[i].name, [this, i]() -> void {
            this->doAction(s_PFMenuItem[i].tag);
        });
    }
    
    _resultInfo = Label::createWithSystemFont("You should see the result at this label", "Arial", 22);
    _resultInfo->setPosition(origin.x + visibleSize.width - _resultInfo->getContentSize().width, origin.y + visibleSize.height / 2);
    _resultInfo->setDimensions(_resultInfo->getContentSize().width, 0);
    addChild(_resultInfo);
    
    _protocolBaaS = static_cast<ParseProtocolBaaS*>(SensparkPluginManager::getInstance()->loadBaaSPlugin(BaaSPluginType::PARSE));
    
    return true;
}

void TestParseBaaS::doAction(int tag) {
    std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestParseBaaS::onParseCallback, this);
    
    switch (tag) {
        case TAG_PF_SIGNUP:
            if (_protocolBaaS->isLoggedIn()) {
                _resultInfo->setString("Parse: please signout first");
            } else {
                _resultInfo->setString("Signup with username: testuser & password: password");
                map<string, string> userInfo;
                userInfo["username"] = "testuser";
                userInfo["password"] = "password";
                userInfo["email"] = "test@google.com";
                
                _protocolBaaS->signUp(userInfo, callback);
            }
            break;
        case TAG_PF_LOGIN: {
            if (_protocolBaaS->isLoggedIn()) {
                _resultInfo->setString("Parse: login already.");
            } else {
                _protocolBaaS->login("testuser", "password", callback);
            }
        }
            break;
        case TAG_PF_LOGOUT: {
            if (_protocolBaaS->isLoggedIn()) {
                _protocolBaaS->logout(callback);
            } else {
                _resultInfo->setString("Parse: logout already.");
            }
            break;
        }
        case TAG_PF_WRITE_OBJECT: {
            
            srand((int) time(nullptr));
            Document doc;
            doc.SetObject();
            Document::AllocatorType &alloc = doc.GetAllocator();
            
            int data = rand() % 100;
            
            string name = StringUtils::format("TestObject%d", data).c_str();
            
            doc.AddMember("name", name.c_str(), alloc);
            doc.AddMember("data",  data, alloc);
            
            StringBuffer buffer;
            Writer<StringBuffer, UTF8<> > writer(buffer);
            doc.Accept(writer);
            
            string sss(buffer.GetString(), buffer.GetString() + strlen(buffer.GetString()));
            
            _resultInfo->setString(StringUtils::format("Parse: writing object... %s", sss.c_str()));
            _protocolBaaS->saveObjectInBackground("testobject", buffer.GetString(), callback);
            
            break;
        }
        case TAG_PF_READ_OBJECT: {
            if (_lastObjectId.length() <= 0) {
                _resultInfo->setString("Please create an object to read");
            } else {
                _protocolBaaS->getObjectInBackground("testobject", _lastObjectId, callback);
            }
            break;
        }
        case TAG_PF_UPDATE_OBJECT: {
            if (_lastObjectId.length() <= 0) {
                _resultInfo->setString("Please read an object.");
            } else {
                Document doc;
                doc.SetObject();
                Document::AllocatorType &alloc = doc.GetAllocator();
                
                int data = rand() % 100;
                
                doc.AddMember("data",  data, alloc);
                
                StringBuffer buffer;
                Writer<StringBuffer, UTF8<> > writer(buffer);
                doc.Accept(writer);
                
                _protocolBaaS->updateObjectInBackground("testobject", _lastObjectId, buffer.GetString(), callback);
            }
        }
        default:
            break;
    }
}

void TestParseBaaS::onParseCallback(int ret, const std::string &result) {
    BaaSActionResultCode code = (BaaSActionResultCode) ret;
    
    switch (code) {
        case cocos2d::plugin::BaaSActionResultCode::kSignUpSucceed:
            _resultInfo->setString("Sign up succeed.");
            break;
        case cocos2d::plugin::BaaSActionResultCode::kSignUpFailed:
            _resultInfo->setString(result.c_str());
            break;
        case BaaSActionResultCode::kLoginSucceed:
            _resultInfo->setString("Login succeed.");
            break;
        case BaaSActionResultCode::kLoginFailed:
            _resultInfo->setString(result);
            break;
        case BaaSActionResultCode::kLogoutSucceed:
            _resultInfo->setString("Logout succeed.");
            log("%s\n", result.c_str());
            break;
        case BaaSActionResultCode::kLogoutFailed:
            _resultInfo->setString(result);
            break;
        case BaaSActionResultCode::kSaveSucceed: {
            _lastObjectId = result;
            _resultInfo->setString(result.c_str());
            break;
        }
        case BaaSActionResultCode::kSaveFailed: {
            _resultInfo->setString(result.c_str());
            break;
        }
        case BaaSActionResultCode::kRetrieveSucceed: {
            log("%s\n", result.c_str());
            _resultInfo->setString(result);
            break;
        }
        case BaaSActionResultCode::kRetrieveFailed: {
            log("%s\n", result.c_str());
            _resultInfo->setString(result);
            break;
        }
        case BaaSActionResultCode::kUpdateFailed: {
            log("%s\n", result.c_str());
            _resultInfo->setString(result);
            break;
        }
        case BaaSActionResultCode::kUpdateSucceed: {
            log("%s\n", result.c_str());
            _resultInfo->setString(_protocolBaaS->getObject("testobject", _lastObjectId));
            break;
        }
        default:
            break;
    }
}
