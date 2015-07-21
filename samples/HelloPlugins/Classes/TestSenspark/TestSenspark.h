//
//  TestSenspark.h
//  HelloPlugins
//
//  Created by Duc Nguyen on 7/17/15.
//
//

#ifndef __HelloPlugins__TestSenspark__
#define __HelloPlugins__TestSenspark__

#include "cocos2d.h"
#include "ListLayer.h"

namespace senspark {

class TestSenspark : public ListLayer {
public:
    static cocos2d::Scene* scene();
    
    virtual bool init();
    
    CREATE_FUNC(TestSenspark);
};
    
}

#endif /* defined(__HelloPlugins__TestSenspark__) */
