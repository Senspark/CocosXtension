/****************************************************************************
Copyright (c) 2013 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "TestGooglePlayScene.h"
#include "SensparkPlugin.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;
using namespace cocos2d::plugin;
using namespace cocos2d::ui;

USING_NS_SENSPARK_PLUGIN;
USING_NS_SENSPARK_PLUGIN_USER;

enum {
    TAG_GP_LOGIN = 1,
    TAG_GP_LOGOUT,
    TAG_GP_SHOW_LEADERBOARDS,
    TAG_GP_SUBMIT_SCORE,
    TAG_GP_SHOW_ACHIEVEMENTS,
    TAG_GP_UNLOCK_ACHIEVEMENT,
    TAG_GP_REVEAL_ACHIEVEMENT,
    TAG_GP_RESET_ACHIEVEMENTS,
    TAG_GP_SHOW_SNAPSHOTS,
    TAG_GP_OPEN_SNAPSHOT,
    TAG_GP_READ_SNAPSHOT,
    TAG_GP_COMMIT_SNAPSHOT,
//    TAG_GP_GETUID,
//    TAG_FB_GETTOKEN,
//    TAG_FB_GETPERMISSIONS,
//    TAG_FB_REQUEST_API,
//    TAG_FB_PUBLISH_INSTALL,
//    TAG_FB_LOG_EVENT,
//    TAG_FB_LOG_PURCHASE,
};

struct GPEventMenuItem {
    const char* name;
    int tag;
};

static GPEventMenuItem s_GPMenuItem[] =
{
    {"login", TAG_GP_LOGIN},
    {"logout", TAG_GP_LOGOUT},
    {"show leaderboards", TAG_GP_SHOW_LEADERBOARDS},
    {"show achievements", TAG_GP_SHOW_ACHIEVEMENTS},
    {"submit score", TAG_GP_SUBMIT_SCORE},
    {"unlock achievement", TAG_GP_UNLOCK_ACHIEVEMENT},
    {"reveal achievement", TAG_GP_REVEAL_ACHIEVEMENT},
    {"reset achievements", TAG_GP_RESET_ACHIEVEMENTS},
    {"show snapshots", TAG_GP_SHOW_SNAPSHOTS},
    {"open snapshot", TAG_GP_OPEN_SNAPSHOT},
    {"read snapshot", TAG_GP_READ_SNAPSHOT},
    {"commit snapshot", TAG_GP_COMMIT_SNAPSHOT},
    {nullptr, 0},
};

Scene* TestGooglePlay::scene()
{
    // 'scene' is an autorelease object
    Scene *scene = Scene::create();
    
    // 'layer' is an autorelease object
    TestGooglePlay *layer = TestGooglePlay::create();

    // add layer as a child to scene
    scene->addChild(layer);

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool TestGooglePlay::init()
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
    auto title = Label::createWithSystemFont("Test Google Play", "Arial", 32);
    title->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height - 64);
    addChild(title);
    
    std::string sdkVersion = "SDK Version is: 1.4.1";
    auto subTitle = Label::createWithSystemFont(sdkVersion.c_str(), "Arial", 18);
    subTitle->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height - 88);
    addChild(subTitle);
    
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
    
    _protocolGooglePlayUser = static_cast<GooglePlayProtocolUser*>(SensparkPluginManager::getInstance()->loadUserPlugin(UserPluginType::GOOGLE_PLAY));

    assert(_protocolGooglePlayUser != nullptr);

    _protocolGooglePlayUser->setCallback(CC_CALLBACK_2(TestGooglePlay::onUserCallback, this));
    _protocolGooglePlayUser->configureUser(GOOGLE_PLAY_KEY_IOS);
    _protocolGooglePlayUser->setDebugMode(true);
    
    _protocolGooglePlaySocial = static_cast<GooglePlayProtocolSocial*>(SensparkPluginManager::getInstance()->loadSocialPlugin(SocialPluginType::GOOGLE_PLAY));
    
    assert(_protocolGooglePlaySocial != nullptr);
    
    _protocolGooglePlaySocial->configureSocial(GOOGLE_PLAY_KEY_IOS);
    _protocolGooglePlaySocial->setDebugMode(true);

    _protocolGooglePlayData = static_cast<GooglePlayProtocolData*>(SensparkPluginManager::getInstance()->loadDataPlugin(DataPluginType::GOOGLE_PLAY));
    _protocolGooglePlayData->setCallback(CC_CALLBACK_3(TestGooglePlay::onDataCallback, this));
//    _protocolGooglePlayData->configure(GOOGLE_PLAY_KEY_IOS);
    _protocolGooglePlayData->setSnapshotListTitle("Test Google Play Data");
    _protocolGooglePlayData->setAllowDeleteForSnapshotListLauncher(true);
    _protocolGooglePlayData->setAllowCreateForSnapshotListLauncher(true);
    _protocolGooglePlayData->setMaxSaveSlots(4);
    
    return true;
}

void TestGooglePlay::doAction(int tag) {
    switch (tag) {
        case TAG_GP_LOGIN: {
            //    std::function<void(int, std::string&)> callback = std::bind(&TestGooglePlay::onUserCallback, this, std::placeholders::_1, std::placeholders::_2);
            //use cocos utils
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestGooglePlay::onUserCallback, this);
            _protocolGooglePlayUser->login(callback);
        }
            break;
        case TAG_GP_LOGOUT: {
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestGooglePlay::onUserCallback, this);
            _protocolGooglePlayUser->logout(callback);
            break;
        }
        case TAG_GP_SHOW_LEADERBOARDS: {
            _protocolGooglePlaySocial->showLeaderboards();
            break;
        }
        case TAG_GP_SHOW_ACHIEVEMENTS: {
            _protocolGooglePlaySocial->showAchievements();
            break;
        }
        case TAG_GP_SUBMIT_SCORE: {
            UserDefault* userDefault = UserDefault::getInstance();
            int score = userDefault->getIntegerForKey("high-score", 1000) + 1;
            userDefault->setIntegerForKey("high-score", score);
            userDefault->flush();
            _protocolGooglePlaySocial->submitScore(GOOGLE_PLAY_LEADERBOARD_KEY_IOS_EASY, score, CC_CALLBACK_2(TestGooglePlay::onSocialCallback, this));
            _resultInfo->setString(StringUtils::format("Submitting new high score: %d", score));
            break;
        }
        case TAG_GP_UNLOCK_ACHIEVEMENT: {
            _protocolGooglePlaySocial->unlockAchievement(GOOGLE_PLAY_ACHIEVEMENT_KEY_IOS_PRIME);
            _resultInfo->setString("Unlocking Achievement PRIME");
            break;
        }
        case TAG_GP_RESET_ACHIEVEMENTS: {
            _resultInfo->setString("Resetting all achievements...");
            _protocolGooglePlaySocial->resetAchievements(CC_CALLBACK_2(TestGooglePlay::onSocialCallback, this));
            break;
        }
        case TAG_GP_SHOW_SNAPSHOTS: {
            _resultInfo->setString("Show snapshot list");
            _protocolGooglePlayData->showSnapshotList();
            break;
        }
        case TAG_GP_OPEN_SNAPSHOT: {
            _resultInfo->setString("Opening snapshot with name: Default");
            _protocolGooglePlayData->openData("Default", kConflictPolicyLastKnownGood);
            break;
        }
        case TAG_GP_READ_SNAPSHOT: {
            _resultInfo->setString("Reading snapshot content");
            _protocolGooglePlayData->readCurrentData();
            break;
        }
        case TAG_GP_COMMIT_SNAPSHOT: {
            srand((int)time(0));
            int data = rand();
            
            _resultInfo->setString(StringUtils::format("Write data with value: %d and commit", data));
            _protocolGooglePlayData->commitData(&data, sizeof(data), nullptr, "Update value.");
        }
            
        default:
            break;
    }
}

void TestGooglePlay::onUserCallback(int code, std::string &msg) {
    log("%s", msg.c_str());
    
    _resultInfo->setString(msg);
}

void TestGooglePlay::onSocialCallback(int code, std::string &msg) {
    log("%s", msg.c_str());
    
    _resultInfo->setString(msg);
}

void TestGooglePlay::onDataCallback(int code, void *data, int64_t length) {
    if (code == kOpenSucceed) {
        _resultInfo->setString("Open file successful.");
    } else if (code == kOpenFailed) {
        _resultInfo->setString("Open file failed.");
    } else if (code == kOpenConflicting) {
        _resultInfo->setString("Open file conflicting.");
    } else if (code == kReadSucceed) {
        int saved = *(int*) data;
        _resultInfo->setString(StringUtils::format("Data contain value: %d, bytecount: %lld", saved, length));
    } else if (code == kReadFailed) {
        _resultInfo->setString("Reading file failed");
    } else if (code == kWriteSucceed) {
        _resultInfo->setString("Write successfully.");
    } else if (code == kWriteFailed) {
        _resultInfo->setString("Write failed.");
    }
}
