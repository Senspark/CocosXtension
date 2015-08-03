//
//  TestFacebookScene.cpp
//  HelloPlugins
//
//  Created by Duc Nguyen on 8/3/15.
//
//

#include "TestFacebookScene.h"
#include "SensparkPlugin.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;
using namespace cocos2d::plugin;
using namespace cocos2d::ui;

USING_NS_SENSPARK_PLUGIN;
USING_NS_SENSPARK_PLUGIN_USER;

enum {
    TAG_FB_LOGIN = 1,
    TAG_FB_LOGIN_WITH_PERMISSION,
    TAG_FB_LOGOUT,
    TAG_FB_SHOW_LEADERBOARDS,
    TAG_FB_SUBMIT_SCORE,
    TAG_FB_SHOW_ACHIEVEMENTS,
    TAG_FB_UNLOCK_ACHIEVEMENT,
    TAG_FB_REVEAL_ACHIEVEMENT,
    TAG_FB_RESET_ACHIEVEMENTS
    //    TAG_FB_GETUID,
    //    TAG_FB_GETTOKEN,
    //    TAG_FB_GETPERMISSIONS,
    //    TAG_FB_REQUEST_API,
    //    TAG_FB_PUBLISH_INSTALL,
    //    TAG_FB_LOG_EVENT,
    //    TAG_FB_LOG_PURCHASE,
};

struct FBEventMenuItem {
    const char* name;
    int tag;
};

static FBEventMenuItem s_GPMenuItem[] =
{
    {"login", TAG_FB_LOGIN},
    {"loginWithPermission", TAG_FB_LOGIN_WITH_PERMISSION},
    {"logout", TAG_FB_LOGOUT},
    {"show leaderboards", TAG_FB_SHOW_LEADERBOARDS},
    {"show achievements", TAG_FB_SHOW_ACHIEVEMENTS},
    {"submit score", TAG_FB_SUBMIT_SCORE},
    {"unlock achievement", TAG_FB_UNLOCK_ACHIEVEMENT},
    {"reset achievements", TAG_FB_RESET_ACHIEVEMENTS},
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
    
    _protocolGameCenterSocial = static_cast<GameCenterProtocolSocial*>(SensparkPluginManager::getInstance()->loadSocialPlugin(SocialPluginType::GAME_CENTER));
    
    assert(_protocolGameCenterSocial != nullptr);
    
    _protocolGameCenterSocial->configureSocial();
    _protocolGameCenterSocial->setDebugMode(true);
    
    
    return true;
}

void TestFacebook::doAction(int tag) {
    switch (tag) {
        case TAG_FB_LOGIN: {
            //    std::function<void(int, std::string&)> callback = std::bind(&TestFacebook::onUserCallback, this, std::placeholders::_1, std::placeholders::_2);
            //use cocos utils
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestFacebook::onUserCallback, this);
            
            
            if (_protocolFacebookUser->isLoggedIn()) {
                _resultInfo->setString("GameCenter: log in already.");
            } else {
                _protocolFacebookUser->login(callback);
            }
        }
            break;
        case TAG_FB_LOGOUT: {
            std::function<void(int, std::string&)> callback = CC_CALLBACK_2(TestFacebook::onUserCallback, this);
            _protocolFacebookUser->logout(callback);
            break;
        }
        case TAG_FB_SHOW_LEADERBOARDS: {
            _protocolGameCenterSocial->showLeaderboards();
            break;
        }
        case TAG_FB_SHOW_ACHIEVEMENTS: {
            _protocolGameCenterSocial->showAchievements();
            break;
        }
        case TAG_FB_SUBMIT_SCORE: {
            UserDefault* userDefault = UserDefault::getInstance();
            int score = userDefault->getIntegerForKey("high-score", 1000) + 1;
            _protocolGameCenterSocial->submitScore(GAME_CENTER_LEADERBOARD_KEY_IOS_EASY, score, CC_CALLBACK_2(TestFacebook::onSocialCallback, this));
            _resultInfo->setString(StringUtils::format("Submitting new high score: %d", score));
            break;
        }
        case TAG_FB_UNLOCK_ACHIEVEMENT: {
            _protocolGameCenterSocial->unlockAchievement(GAME_CENTER_ACHIEVEMENT_KEY_IOS_PRIME);
            _resultInfo->setString("Unlocking Achievement PRIME");
            break;
        }
        case TAG_FB_RESET_ACHIEVEMENTS: {
            _resultInfo->setString("Resetting all achievements...");
            _protocolGameCenterSocial->resetAchievements(CC_CALLBACK_2(TestFacebook::onSocialCallback, this));
            break;
        }
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
