//
//  TestSenspark.cpp
//  HelloPlugins
//
//  Created by Duc Nguyen on 7/17/15.
//
//

#include "TestSenspark.h"
#include "TestGoogleAnalyticsScene.h"
#include "TestGooglePlayScene.h"
#include "TestSensparkAdsScene.h"

using namespace senspark;
USING_NS_CC;

void pushScene(Scene* scene) {
    Director::getInstance()->pushScene(scene);
}

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
    
    addTest("Analytics - Google", []() { pushScene(TestGoogleAnalytics::scene()); });
    addTest("Analytics - Flurry", []() { pushScene(Scene::create()); });
    
    addTest("Ads", []() { pushScene(TestSensparkAds::scene()); });

    addTest("Game Service - Google Play", []() { pushScene(TestGooglePlay::scene()); });
    addTest("Game Service - Game Center", []() { pushScene(Scene::create()); });
    
    addTest("Social - Facebook", []() { pushScene(Scene::create()); });
    addTest("Cloud Sync - Parse", []() { pushScene(Scene::create()); });
    
    addTest("User - Facebook", []() { pushScene(Scene::create()); });
    
    return true;
}

