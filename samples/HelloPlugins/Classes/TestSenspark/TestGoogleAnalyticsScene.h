//
//  TestGoogleAnalyticsScene.h
//  HelloPlugins
//
//  Created by Duc Nguyen on 7/20/15.
//
//

#ifndef __HelloPlugins__TestGoogleAnalyticsScene__
#define __HelloPlugins__TestGoogleAnalyticsScene__

#include <stdio.h>
#include "cocos2d.h"
#include "Configs.h"

#include "ListLayer.h"
#include "SensparkPlugin.h"

USING_NS_CC;

NS_SENSPARK_BEGIN

enum class MenuItemTag {
    TAG_LOG_SCREEN,
    TAG_LOG_EVENT,
    TAG_LOG_TIMING,
    TAG_LOG_SOCIAL,
    TAG_MAKE_ME_CRASH,
};

struct EventMenuItem {
    std::string title;
    MenuItemTag tag;
};

class TestGoogleAnalytics : public ListLayer {
public:
    virtual bool init();
    
    virtual void onEnter();
    virtual void onExit();
    
    void doAction(MenuItemTag tag);
    
    static Scene* scene();
    
    CREATE_FUNC(TestGoogleAnalytics);

private:
    senspark::plugin::analytics::GoogleProtocolAnalytics* _pluginAnalytics;
};

NS_SENSPARK_END
    

#endif /* defined(__HelloPlugins__TestGoogleAnalyticsScene__) */
