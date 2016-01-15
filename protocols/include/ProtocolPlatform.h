//
//  ProtocolPlatform.h
//  PluginProtocol
//
//  Created by Duc Nguyen on 1/5/16.
//  Copyright © 2016 zhangbin. All rights reserved.
//

#ifndef ProtocolPlatform_h
#define ProtocolPlatform_h

#include "PluginProtocol.h"
#include <string>
#include <functional>

NS_CC_PLUGIN_BEGIN

enum class PlatformResultCode {
    kConnected = 1,
    kUnconnected,
};

class ProtocolPlatform : public cocos2d::plugin::PluginProtocol {
public:
    ProtocolPlatform();
    virtual ~ProtocolPlatform();

    typedef std::function<void(PlatformResultCode, const std::string&)> PlatformCallback;

    bool isAppInstalled(const std::string& url);
    
    bool isConnected(const std::string& hostName);

    std::string getSHA1CertFingerprint();
    
    bool isRelease();

    double getVersionCode();
    
    void sendFeedback(const std::string& appName);
    /**
     @brief set login callback function
     */
    inline void setCallback(const PlatformCallback &cb)
    {
        _callback = cb;
    }
    
    /**
     @brief get login callback function
     */
    inline PlatformCallback& getCallback()
    {
        return _callback;
    }
    
protected:
    PlatformCallback _callback;
    
};

NS_CC_PLUGIN_END

#endif /* ProtocolPlatform_h */
