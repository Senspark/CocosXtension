//
//  TestFacebookScene.cpp
//  HelloPlugins
//
//  Created by Duc Nguyen on 8/3/15.
//
//

#include "TestFacebookScene.h"
#include "cocos-ext.h"
#include "SensparkPlugin.h"
#include "FacebookAgent.h"
#include "ProtocolUser.h"

USING_NS_CC;
USING_NS_CC_EXT;
using namespace cocos2d::plugin;
using namespace cocos2d::ui;

USING_NS_SENSPARK_PLUGIN;
USING_NS_SENSPARK_PLUGIN_USER;

enum {
    TAG_FB_LOGIN = 1,
    TAG_FB_LOGIN_WITH_READ_PERMISSION,
    TAG_FB_LOGIN_WITH_PUBLISH_PERMISSION,
    TAG_FB_LOGOUT,
    TAG_FB_GETUID,
    TAG_FB_GETINFO,
    TAG_FB_GETTOKEN,
    TAG_FB_GRAPH_REQUEST,
    TAG_FB_PERMISSION,
};

struct FBEventMenuItem {
    const char* name;
    int tag;
};

static FBEventMenuItem s_GPMenuItem[] =
{
    {"login", TAG_FB_LOGIN},
    {"login with read permission", TAG_FB_LOGIN_WITH_READ_PERMISSION},
    {"login with publish permission", TAG_FB_LOGIN_WITH_PUBLISH_PERMISSION},
    {"logout", TAG_FB_LOGOUT},
    {"user ID", TAG_FB_GETUID},
    {"user info", TAG_FB_GETINFO},
    {"access token", TAG_FB_GETTOKEN},
    {"graph request", TAG_FB_GRAPH_REQUEST},
    {"permissions", TAG_FB_PERMISSION},
    {nullptr, 0},
};

Scene* TestFacebook::scene()
{
    // 'scene' is an autorelease object
    Scene *scene = Scene::create();
    
    // 'layer' is an autorelease object
    TestFacebook *layer = TestFacebook::create();
    
    // add layer as a child to scene
    scene->addChild(layer);
    
    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool TestFacebook::init()
{
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
    auto title = Label::createWithSystemFont("Test Facebook", "Arial", 32);
    title->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height - 64);
    addChild(title);
    
    //    std::string sdkVersion = "SDK Version is: 1.4.1";
    //    auto subTitle = Label::createWithSystemFont(sdkVersion.c_str(), "Arial", 18);
    //    subTitle->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height - 88);
    //    addChild(subTitle);
    
    _testListView->setViewSize(Size(visibleSize.width / 3, visibleSize.height / 2));
    _testListView->setPosition(origin + Size(0, visibleSize.height / 4));
    
    for (int i = 0; s_GPMenuItem[i].name != nullptr; i++) {
        addTest(s_GPMenuItem[i].name, [this, i]() -> void {
            this->doAction(s_GPMenuItem[i].tag);
        });
    }
    
    _resultInfo = Label::createWithSystemFont("You should see the result at this label", "Arial", 22);
    _resultInfo->setPosition(origin.x + visibleSize.width - _resultInfo->getContentSize().width, origin.y + visibleSize.height / 2);
    _resultInfo->setDimensions(_resultInfo->getContentSize().width, 0);
    addChild(_resultInfo);
    
    _protocolFacebookUser = static_cast<FacebookProtocolUser*>(SensparkPluginManager::getInstance()->loadUserPlugin(UserPluginType::FACEBOOK));
    
    assert(_protocolFacebookUser != nullptr);
    
    _protocolFacebookUser->setCallback(CC_CALLBACK_2(TestFacebook::onUserCallback, this));
    _protocolFacebookUser->setDebugMode(true);
    
    
    return true;
}

void TestFacebook::doAction(int tag) {
    switch (tag) {
        case TAG_FB_LOGIN: {
            //    std::function<void(int, std::string&)> callback = std::bind(&TestFacebook::onUserCallback, this, std::placeholders::_1, std::placeholders::_2);
            //use cocos utils
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestFacebook::onUserCallback, this);
            
            
            if (_protocolFacebookUser->isLoggedIn()) {
                _resultInfo->setString("Facebook: log in already.");
            } else {
                _protocolFacebookUser->login(callback);
            }
        }
            break;
        case TAG_FB_LOGIN_WITH_READ_PERMISSION: {
            std::string permissions = "public_profile, email, user_about_me, user_friends";
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestFacebook::onUserCallback, this);
            
            _protocolFacebookUser->loginWithReadPermissions(permissions, callback);
            break;
        }
        case TAG_FB_LOGIN_WITH_PUBLISH_PERMISSION: {
            std::string permissions = "publish_actions";
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestFacebook::onUserCallback, this);
            
            _protocolFacebookUser->loginWithPublishPermissions(permissions, callback);
            break;
        }
        case TAG_FB_LOGOUT: {
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestFacebook::onUserCallback, this);
            _protocolFacebookUser->logout(callback);
            break;
        }
        case TAG_FB_GETUID: {
            _resultInfo->setString(_protocolFacebookUser->getUserID());
            break;
        }
        case TAG_FB_GETINFO: {
            FacebookProtocolUser::FBCallback callback = CC_CALLBACK_2(TestFacebook::onGraphRequestCallback, this);
            
            FacebookProtocolUser::FBParam param;
            param["fields"] = "picture.type(square),name,id";
            _protocolFacebookUser->graphRequest("me", param, callback);
            _resultInfo->setString("Call graph request to query user info...");
            break;
        }
        case TAG_FB_GETTOKEN: {
            _resultInfo->setString(_protocolFacebookUser->getAccessToken());
            break;
        }
        case TAG_FB_PERMISSION: {
            _resultInfo->setString("Call graph request for something...");
            std::string path = "me/permissions";
            FacebookAgent::FBParam params;
            FacebookAgent::getInstance()->api(path, FacebookAgent::HttpMethod::Get, params, [=](int ret, std::string& msg){
                _resultInfo->setString(msg.c_str());
            });
        }
            break;
        case TAG_FB_GRAPH_REQUEST:
        {
            std::string path = "/me/photos";
            FacebookAgent::FBParam params;
            params["url"] = "http://files.cocos2d-x.org/images/orgsite/logo.png";
            FacebookAgent::getInstance()->api(path, FacebookAgent::HttpMethod::Post, params, [=](int ret, std::string& msg){
                if (0 == ret) {
                    _resultInfo->setString(msg.c_str());
                } else {
                    _resultInfo->setString("Error! Please login with publish permissions then retry again.");
                }
            });
        }
            break;
        default:
            break;
    }
}

void TestFacebook::onUserCallback(int code, std::string &msg) {
    log("%s", msg.c_str());
    
    _resultInfo->setString(msg);
}

void TestFacebook::onSocialCallback(int code, std::string &msg) {
    log("%s", msg.c_str());
    
    _resultInfo->setString(msg);
}

void TestFacebook::onGraphRequestCallback(int code, std::string &result) {
    
    log("code: %d, result: %s", code, result.c_str());
    _resultInfo->setString(result);
}
