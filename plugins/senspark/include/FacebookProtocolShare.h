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

#define KEY_RECIPIENTS  "recipients"
#define KEY_TITLE       "title"
#define KEY_MESSAGE     "message"
#define KEY_ACTION_TYPE "action-type"
#define KEY_OBJECT_ID   "object-id"
#define KEY_DATA        "data"

class FacebookProtocolShare : public cocos2d::plugin::ProtocolShare
{
public:
    
    typedef std::map<std::string, std::string> FBParam;
    
    FacebookProtocolShare();
    virtual ~FacebookProtocolShare();
    
    void share(FBParam& info, FacebookProtocolShare::ShareCallback& callback);
    
    void openInviteDialog(FBParam &info, FacebookProtocolShare::ShareCallback& callback);
    
    void sendGameRequest(FBParam &info, FacebookProtocolShare::ShareCallback& callback);
private:
};

NS_SENSPARK_PLUGIN_SHARE_END

#endif
