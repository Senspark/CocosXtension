//
//  BaasboxProtocolBaas.h
//  PluginSenspark
//
//  Created by Tran Van Tuan on 12/22/15.
//  Copyright © 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef BaasboxProtocolBaas_h
#define BaasboxProtocolBaas_h


#include "ProtocolBaaS.h"
#include "SensparkPluginMacros.h"
#include <string>
#include <map>

NS_SENSPARK_PLUGIN_BAAS_BEGIN

class BaasboxProtocolBaaS : public cocos2d::plugin::ProtocolBaaS
{
public:
    virtual ~BaasboxProtocolBaaS();
    
    void loginWithFacebookToken(const std::string& facebookToken, BaaSCallback &cb);
    
    void updateUserProfile(const std::string& profile, BaaSCallback &cb);
    
    void fetchUserProfile(BaaSCallback &cb);
    
    void loadUsersWithParameters(const std::string& condition, BaaSCallback &cb);
    
    void loadAssetJSON(const std::string& assetName, BaaSCallback &cb);
};

NS_SENSPARK_PLUGIN_BAAS_END

#endif /* BaasboxProtocolBaas_h */
