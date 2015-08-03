//
//  TestGameCenterScene.cpp
//  HelloPlugins
//
//  Created by Duc Nguyen on 7/31/15.
//
//

#include "TestGameCenterScene.h"
#include "SensparkPlugin.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;
using namespace cocos2d::plugin;
using namespace cocos2d::ui;

USING_NS_SENSPARK_PLUGIN;
USING_NS_SENSPARK_PLUGIN_USER;

enum {
    TAG_GC_LOGIN = 1,
    //    TAG_FB_LOGIN_WITH_PERMISSION,
    TAG_GC_LOGOUT,
    TAG_GC_SHOW_LEADERBOARDS,
    TAG_GC_SUBMIT_SCORE,
    TAG_GC_SHOW_ACHIEVEMENTS,
    TAG_GC_UNLOCK_ACHIEVEMENT,
    TAG_GC_REVEAL_ACHIEVEMENT,
    TAG_GC_RESET_ACHIEVEMENTS
    //    TAG_GC_GETUID,
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
    {"login", TAG_GC_LOGIN},
    {"logout", TAG_GC_LOGOUT},
    {"show leaderboards", TAG_GC_SHOW_LEADERBOARDS},
    {"show achievements", TAG_GC_SHOW_ACHIEVEMENTS},
    {"submit score", TAG_GC_SUBMIT_SCORE},
    {"unlock achievement", TAG_GC_UNLOCK_ACHIEVEMENT},
    {"reset achievements", TAG_GC_RESET_ACHIEVEMENTS},
    {nullptr, 0},
};

Scene* TestGameCenter::scene()
{
    // 'scene' is an autorelease object
    Scene *scene = Scene::create();
    
    // 'layer' is an autorelease object
    TestGameCenter *layer = TestGameCenter::create();
    
    // add layer as a child to scene
    scene->addChild(layer);
    
    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool TestGameCenter::init()
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
    auto title = Label::createWithSystemFont("Test Game Center", "Arial", 32);
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
    
    _protocolGameCenterUser = static_cast<GameCenterProtocolUser*>(SensparkPluginManager::getInstance()->loadUserPlugin(UserPluginType::GAME_CENTER));
    
    assert(_protocolGameCenterUser != nullptr);
    
    _protocolGameCenterUser->setCallback(CC_CALLBACK_2(TestGameCenter::onUserCallback, this));
    _protocolGameCenterUser->setDebugMode(true);
    
    _protocolGameCenterSocial = static_cast<GameCenterProtocolSocial*>(SensparkPluginManager::getInstance()->loadSocialPlugin(SocialPluginType::GAME_CENTER));
    
    assert(_protocolGameCenterSocial != nullptr);
    
    _protocolGameCenterSocial->configureSocial();
    _protocolGameCenterSocial->setDebugMode(true);
    
    
    return true;
}

void TestGameCenter::doAction(int tag) {
    switch (tag) {
        case TAG_GC_LOGIN: {
            //    std::function<void(int, std::string&)> callback = std::bind(&TestGameCenter::onUserCallback, this, std::placeholders::_1, std::placeholders::_2);
            //use cocos utils
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestGameCenter::onUserCallback, this);
            
            
            if (_protocolGameCenterUser->isLoggedIn()) {
                _resultInfo->setString("GameCenter: log in already.");
            } else {
                _protocolGameCenterUser->login(callback);
            }
        }
            break;
        case TAG_GC_LOGOUT: {
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestGameCenter::onUserCallback, this);
            _protocolGameCenterUser->logout(callback);
            break;
        }
        case TAG_GC_SHOW_LEADERBOARDS: {
            _protocolGameCenterSocial->showLeaderboards();
            break;
        }
        case TAG_GC_SHOW_ACHIEVEMENTS: {
            _protocolGameCenterSocial->showAchievements();
            break;
        }
        case TAG_GC_SUBMIT_SCORE: {
            UserDefault* userDefault = UserDefault::getInstance();
            int score = userDefault->getIntegerForKey("high-score", 1000) + 1;
            _protocolGameCenterSocial->submitScore(GAME_CENTER_LEADERBOARD_KEY_IOS_EASY, score, CC_CALLBACK_2(TestGameCenter::onSocialCallback, this));
            _resultInfo->setString(StringUtils::format("Submitting new high score: %d", score));
            break;
        }
        case TAG_GC_UNLOCK_ACHIEVEMENT: {
            _protocolGameCenterSocial->unlockAchievement(GAME_CENTER_ACHIEVEMENT_KEY_IOS_PRIME);
            _resultInfo->setString("Unlocking Achievement PRIME");
            break;
        }
        case TAG_GC_RESET_ACHIEVEMENTS: {
            _resultInfo->setString("Resetting all achievements...");
            _protocolGameCenterSocial->resetAchievements(CC_CALLBACK_2(TestGameCenter::onSocialCallback, this));
            break;
        }
        default:
            break;
    }
}

void TestGameCenter::onUserCallback(int code, std::string &msg) {
    log("%s", msg.c_str());
    
    _resultInfo->setString(msg);
}

void TestGameCenter::onSocialCallback(int code, std::string &msg) {
    log("%s", msg.c_str());
    
    _resultInfo->setString(msg);
}
