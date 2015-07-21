//
//  TestSenspark.cpp
//  HelloPlugins
//
//  Created by Duc Nguyen on 7/17/15.
//
//

#include "TestSenspark.h"
#include "TestGoogleAnalyticsScene.h"

using namespace senspark;
USING_NS_CC;

Scene* TestSenspark::scene() {
    // 'scene' is an autorelease object
    Scene *scene = Scene::create();
    
    // 'layer' is an autorelease object
    TestSenspark *layer = TestSenspark::create();
    layer->setTag(MAIN_LAYER_TAG);
    // add layer as a child to scene
    scene->addChild(layer);
    
    // return the scene
    return scene;
}

bool TestSenspark::init() {
    if (!ListLayer::init()) {
        return false;
    }
    
    addTest("Analytics - Google", TestGoogleAnalytics::scene());
    addTest("Analytics - Flurry", Scene::create());
    
    addTest("Ads - Google Admob", Scene::create());
    addTest("Ads - Flurry", Scene::create());
    addTest("Ads - Vungle", Scene::create());
    addTest("Ads - Chartboost", Scene::create());

    addTest("Game Service - Google Play", Scene::create());
    addTest("Game Service - Game Center", Scene::create());
    
    addTest("Social - Facebook", Scene::create());
    addTest("Cloud Sync - Parse", Scene::create());
    
    addTest("User - Facebook", Scene::create());
    
    return true;
}

