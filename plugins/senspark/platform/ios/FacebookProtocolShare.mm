//
//  FacebookProtocolShare.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "FacebookProtocolShare.h"
#include "AgentManager.h"

NS_SENSPARK_PLUGIN_SHARE_BEGIN
static FacebookProtocolShare* s_sharedFacebookProtocolShare = nullptr;

FacebookProtocolShare* FacebookProtocolShare::getInstance(){
    if(nullptr == s_sharedFacebookProtocolShare){
        s_sharedFacebookProtocolShare = new (std::nothrow)FacebookProtocolShare();
    }
    return s_sharedFacebookProtocolShare;
}

void FacebookProtocolShare::fetchInvitableFriendsList(FBParam &info, FBCallback cb){
    auto sharePlugin = cocos2d::plugin::AgentManager::getInstance()->getSharePlugin();
    sharePlugin->setCallback(cb);
    cocos2d::plugin::PluginParam params(info);
    sharePlugin->callFuncWithParam("fetchInvitableFriendList", &params, NULL);
}

void FacebookProtocolShare::openInviteDialog(FBParam &info, FBCallback cb){
    auto sharePlugin = cocos2d::plugin::AgentManager::getInstance()->getSharePlugin();
    sharePlugin->setCallback(cb);
    cocos2d::plugin::PluginParam params(info);
    sharePlugin->callFuncWithParam("openInviteDialog", &params, NULL);
}

NS_SENSPARK_PLUGIN_SHARE_END
