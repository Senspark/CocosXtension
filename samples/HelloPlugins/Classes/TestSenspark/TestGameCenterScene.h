//
//  TestGameCenterScene.h
//  HelloPlugins
//
//  Created by Duc Nguyen on 7/31/15.
//
//

#ifndef __HelloPlugins__TestGameCenterScene__
#define __HelloPlugins__TestGameCenterScene__

#include "cocos2d.h"
#include "ListLayer.h"
#include "SensparkPlugin.h"
#include "ProtocolUser.h"
#include <string>

USING_NS_SENSPARK_PLUGIN_USER;
USING_NS_SENSPARK_PLUGIN_SOCIAL;
USING_NS_SENSPARK;

class TestGameCenter : public ListLayer
{
public:
    // Here's a difference. Method 'init' in cocos2d-x returns bool, instead of returning 'id' in cocos2d-iphone
    virtual bool init();
    
    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::Scene* scene();
    
    // implement the "static node()" method manually
    CREATE_FUNC(TestGameCenter);
    
    void doAction(int tag);
    
    void onUserCallback(int code, std::string& msg);
    void onSocialCallback(int code, std::string& msg);
    
private:
    GameCenterProtocolUser* _protocolGameCenterUser;
    GameCenterProtocolSocial* _protocolGameCenterSocial;
    
    Label* _resultInfo;
    
};

#endif // __TEST_USER_SCENE_H__