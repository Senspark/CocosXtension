//
//  FacebookProtocolShare.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_FacebookProtocolShare_h
#define PluginSenspark_FacebookProtocolShare_h

#include "ProtocolShare.h"
#include "SensparkPluginMacros.h"
#include <string>
#include <map>
#include <vector>
#include <functional>

NS_SENSPARK_PLUGIN_SHARE_BEGIN

class FacebookProtocolShare : public cocos2d::plugin::ProtocolShare
{
public:
    
    static FacebookProtocolShare* getInstance();
    
    typedef std::map<std::string, std::string> FBParam;
    typedef std::function<void(int, std::string&)> FBCallback;
    
    /**
     @brief fetch list friends not play game to invite play game
     @param info info fetch
     @param cb callback of request
     */
    void fetchInvitableFriendsList(FBParam &info, FBCallback cb);
    
    /**
     @brief open invite facebook dialog
     @param info info dialog invite
     @param cb callback of request
     */
    void openInviteDialog(FBParam &info, FBCallback cb);
};

NS_SENSPARK_PLUGIN_SHARE_END

#endif
