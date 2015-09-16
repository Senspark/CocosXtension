//
//  GooglePlayProtocolData.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 8/10/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_GooglePlayProtocolData_h
#define PluginSenspark_GooglePlayProtocolData_h

#include "ProtocolData.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_DATA_BEGIN

class GooglePlayProtocolData : public cocos2d::plugin::ProtocolData
{
public:
    GooglePlayProtocolData();
    virtual ~GooglePlayProtocolData();
    
    void configure(const std::string& clientId);
    
    void setSnapshotListTitle(const std::string& title);
    
    void setAllowCreateForSnapshotListLauncher(bool allow);
    void setAllowDeleteForSnapshotListLauncher(bool allow);
    void setMaxSaveSlots(int maxSlot);
    void showSnapshotList(const std::string& title, bool allowAdd, bool allowDelete, int maxSlots);
};

NS_SENSPARK_PLUGIN_DATA_END

#endif

