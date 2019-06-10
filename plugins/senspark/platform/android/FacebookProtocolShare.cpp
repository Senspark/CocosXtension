
//
//  FacebookProtocolShare.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#include "FacebookProtocolShare.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"

USING_NS_SENSPARK_PLUGIN_SHARE;
using namespace cocos2d::plugin;
using namespace cocos2d;

FacebookProtocolShare::FacebookProtocolShare() {

}

FacebookProtocolShare::~FacebookProtocolShare() {

    PluginUtils::erasePluginJavaData(this);

}


void FacebookProtocolShare::share(FBParam &info, FacebookProtocolShare::ShareCallback& callback) {
    ProtocolShare::share(info, callback);
}

void FacebookProtocolShare::likeFanpage(const std::string &fanpageID) {
    PluginParam param(fanpageID.c_str());

    callFuncWithParam("likeFanpage", &param, nullptr);
}

void FacebookProtocolShare::openInviteDialog(FBParam &info, FacebookProtocolShare::ShareCallback& callback){
    FacebookProtocolShare::CallbackWrapper* wrapper = new FacebookProtocolShare::CallbackWrapper(callback);

    PluginParam params(info);
    PluginParam callbackID((long long)wrapper);

    callFuncWithParam("openInviteDialog", &params, &callbackID, nullptr);
}

void FacebookProtocolShare::sendGameRequest(FBParam &info, FacebookProtocolShare::ShareCallback& callback) {

    PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
                                       "sendGameRequest", "(Ljava/util/Hashtable;I)V")) {

        jobject obj_Map = PluginUtils::createJavaMapObject(&info);

        CallbackWrapper* wrapper = new CallbackWrapper(callback);

        t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map, (long long)wrapper);
        t.env->DeleteLocalRef(obj_Map);
        t.env->DeleteLocalRef(t.classID);
    }
}
