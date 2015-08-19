//
//  TestParseScene.h
//  HelloPlugins
//
//  Created by Duc Nguyen on 8/14/15.
//
//

#ifndef __HelloPlugins__TestParseScene__
#define __HelloPlugins__TestParseScene__

#include <stdio.h>
#include "cocos2d.h"
#include "Configs.h"
#include "ListLayer.h"
#include "SensparkPlugin.h"

USING_NS_SENSPARK;
USING_NS_SENSPARK_PLUGIN;
USING_NS_SENSPARK_PLUGIN_BAAS;

class TestParseBaaS : public ListLayer {
public:
    static Scene* scene();
    
    virtual bool init();
    
    void doAction(int tag);
    
    void onParseCallback(int ret, const std::string& result);
    
    CREATE_FUNC(TestParseBaaS);
    
private:
    ParseProtocolBaaS* _protocolBaaS;
    Label* _resultInfo;
    std::string _lastObjectId;
};

#endif /* defined(__HelloPlugins__TestParseScene__) */
