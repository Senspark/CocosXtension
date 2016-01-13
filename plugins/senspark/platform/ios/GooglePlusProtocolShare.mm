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

    ProtocolShare::share(info, callback);
}