//
//  GooglePlusProtocolShare.m
//  PluginSenspark
//
//  Created by Nikel Arteta on 1/6/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GooglePlusProtocolShare.h"
#include "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_SHARE;
using namespace cocos2d::plugin;

GooglePlusProtocolShare::GooglePlusProtocolShare() {

}

GooglePlusProtocolShare::~GooglePlusProtocolShare() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void GooglePlusProtocolShare::share(GPParam &info, GooglePlusProtocolShare::ShareCallback &callback) {
    GooglePlusProtocolShare::CallbackWrapper* wrapper = new GooglePlusProtocolShare::CallbackWrapper(callback);

    cocos2d::plugin::PluginParam params(info);
    cocos2d::plugin::PluginParam callbackID((long)wrapper);

    callFuncWithParam("share", &params, &callbackID, nullptr);
}