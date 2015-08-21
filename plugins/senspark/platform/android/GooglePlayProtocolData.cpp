//
//  GooglePlayProtocolData.cpp
//  PluginSenspark
//
//  Created by Duc Nguyen on 8/10/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//
#include "GooglePlayProtocolData.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_DATA;
using namespace cocos2d::plugin;

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

void GooglePlayProtocolData::showSnapshotList() {
    callFuncWithParam("presentSnapshotList", nullptr);
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
