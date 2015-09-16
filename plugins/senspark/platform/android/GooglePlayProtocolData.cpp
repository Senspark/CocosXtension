//
//  GooglePlayProtocolData.cpp
//  PluginSenspark
//
//  Created by Duc Nguyen on 8/10/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//
#include "GooglePlayProtocolData.h"
#include "PluginJniHelper.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_DATA;
using namespace cocos2d;
using namespace cocos2d::plugin;
using namespace std;

GooglePlayProtocolData::GooglePlayProtocolData() {
}

GooglePlayProtocolData::~GooglePlayProtocolData() {
    PluginUtils::erasePluginJavaData(this);
}

void GooglePlayProtocolData::configure(const std::string& clientId) {
    TDataDeveloperInfo devInfo;
    devInfo["GoogleClientID"] = clientId;
    configDeveloperInfo(devInfo);
}

void GooglePlayProtocolData::showSnapshotList(const std::string& title, bool allowAdd, bool allowDelete, int maxSlots) {
    PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "presentSnapshotList", "(Ljava/util/Hashtable;)V")) {
        map<string, string> params;
        params["title"] = title;
        params["allowAdd"] = allowAdd ? "true" : "false";
        params["allowDelete"] = allowDelete ? "true" : "false";

        char* strMaxSlots = new char[100] {0};
        sprintf(strMaxSlots, "%d", maxSlots);
        params["maxSlots"] = string(strMaxSlots);
        delete strMaxSlots;

        jobject obj_map = PluginUtils::createJavaMapObject(&params);

        t.env->CallVoidMethod(pData->jobj, t.methodID, obj_map);
        t.env->DeleteLocalRef(obj_map);
        t.env->DeleteLocalRef(t.classID);
    }
}

void GooglePlayProtocolData::setSnapshotListTitle(const std::string &title) {
    PluginParam titleParam(title.c_str());
    callFuncWithParam("setSnapshotListTitle", &titleParam, nullptr);
}

void GooglePlayProtocolData::setAllowCreateForSnapshotListLauncher(bool allow) {
    PluginParam allowParam(allow);
    callFuncWithParam("setShouldAllowSnapshotCreate", &allowParam, nullptr);
}

void GooglePlayProtocolData::setAllowDeleteForSnapshotListLauncher(bool allow) {
    PluginParam allowParam(allow);
    callFuncWithParam("setShouldAllowSnapshotDelete", &allowParam, nullptr);
}

void GooglePlayProtocolData::setMaxSaveSlots(int maxSlot) {
    PluginParam maxSlotParam(maxSlot);
    callFuncWithParam("setMaxSlots", &maxSlotParam, nullptr);
}
