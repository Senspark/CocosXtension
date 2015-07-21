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

#include "SensparkPlugin.h"

USING_NS_CC;

NS_SENSPARK_BEGIN

class TestGoogleAnalytics : public Layer {
public:
    virtual bool init();
    virtual void onExit();
    
    static Scene* scene();
    
    CREATE_FUNC(TestGoogleAnalytics);
    
private:
    senspark::plugin::SensparkProtocolAnalytics* _pluginAnalytics;
    
};

NS_SENSPARK_END
    

#endif /* defined(__HelloPlugins__TestGoogleAnalyticsScene__) */
