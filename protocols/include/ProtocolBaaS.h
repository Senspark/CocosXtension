//
//  ProtocolBaaS.h
//  PluginProtocol
//
//  Created by Duc Nguyen on 8/13/15.
//  Copyright (c) 2015 zhangbin. All rights reserved.
//

#ifndef __CCX_PROTOCOL_BAAS_H__
#define __CCX_PROTOCOL_BAAS_H__

#include "PluginProtocol.h"
#include <string>
#include <functional>


namespace cocos2d { namespace plugin {
    
    enum class BaaSActionResultCode {
        kLoginSucceed = 0,
        kLoginFailed,
        
        kLogoutSucceed,
        kLogoutFailed,
        
        kSignUpSucceed,
        kSignUpFailed,
        
        kSaveSucceed,
        kSaveFailed,
        
        kRetrieveSucceed,
        kRetrieveFailed,
        
        kDeleteSucceed,
        kDeleteFailed,
        
        kUpdateSucceed,
        kUpdateFailed,

        kFetchConfigSucceed,
        kFetchConfigFailed,
    };
    
    typedef std::map<std::string, std::string> TBaaSDeveloperInfo;
    
    class ProtocolBaaS;
    class BaaSActionListener {
    public:
        virtual void onActionResult(ProtocolBaaS* pPlugin, int ret, const std::string& msg) = 0;
    };
    
    class ProtocolBaaS : public PluginProtocol {
    public:
        ProtocolBaaS();
        virtual ~ProtocolBaaS();
        
        typedef std::function<void(int, std::string&)> ProtocolBaaSCallback;
        
        void configDeveloperInfo(TBaaSDeveloperInfo devInfo);
        
        void signUp(std::map<std::string, std::string> userInfo);
        void signUp(std::map<std::string, std::string> userInfo, ProtocolBaaSCallback& cb);
        
        void login(const std::string& username, const std::string& password);
        void login(const std::string& username, const std::string& password, ProtocolBaaSCallback& cb);
        
        void logout();
        void logout(ProtocolBaaSCallback& cb);
        
        bool isLoggedIn();
        
        void saveObjectInBackground(const std::string& className, const std::string& json);
        void saveObjectInBackground(const std::string& className, const std::string& json, ProtocolBaaSCallback& cb);
        
        const char* saveObject(const std::string& className, const std::string& json);

        void getObjectInBackgroundEqualTo(const std::string& equalTo, const std::string& className, const std::string& objId);
        void getObjectInBackgroundEqualTo(const std::string& equalTo, const std::string& className, const std::string& objId, ProtocolBaaSCallback& cb);
        void getObjectInBackground(const std::string& className, const std::string& objId);
        void getObjectInBackground(const std::string& className, const std::string& objId, ProtocolBaaSCallback& cb);
        
        const char* getObject(const std::string& className, const std::string& objId);
        
        void updateObjectInBackground(const std::string& className, const std::string& objId, const std::string& jsonChanges);
        void updateObjectInBackground(const std::string& className, const std::string& objId, const std::string& jSonChanges, ProtocolBaaSCallback& cb);
        
        const char* updateObject(const std::string& className, const std::string& objId, const std::string& jsonChanges);

        void deleteObjectInBackground(const std::string& className, const std::string& objId);
        void deleteObjectInBackground(const std::string& className, const std::string& objId, ProtocolBaaSCallback& cb);

        const char* deleteObject(const std::string& className, const std::string& objId);

        /**
         * Return cached config.
         */
        void fetchConfigInBackground(ProtocolBaaSCallback& cb);
        bool getBoolConfig(const std::string& param);
        int getIntegerConfig(const std::string& param);
        double getDoubleConfig(const std::string& param);
        long getLongConfig(const std::string& param);
        const char* getStringConfig(const std::string& param);
        const char* getArrayConfig(const std::string& param);

        /*
         @deprecated
         @brief set login callback function
         */
        CC_DEPRECATED_ATTRIBUTE inline void setActionListener(BaaSActionListener* listener)
        {
            _listener = listener;
        }
        /*
         @deprecated
         @brief get login callback function
         */
        CC_DEPRECATED_ATTRIBUTE inline BaaSActionListener* getActionListener()
        {
            return _listener;
        }
        
        /**
         @brief set login callback function
         */
        inline void setCallback(const ProtocolBaaSCallback &cb)
        {
            _callback = cb;
        }
        
        /**
         @brief get login callback function
         */
        inline ProtocolBaaSCallback& getCallback()
        {
            return _callback;
        }
        
    protected:
        BaaSActionListener* _listener;
        ProtocolBaaSCallback _callback;
    };
}}

#endif
