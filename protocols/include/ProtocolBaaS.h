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

    typedef std::map<std::string, std::string> TBaaSInfo;
    
    class ProtocolBaaS : public PluginProtocol {
    public:
        typedef std::function<void(int, const std::string&)> BaaSCallback;
        
        typedef struct __CallbackWrapper {
            __CallbackWrapper(BaaSCallback& cb) {
                fnPtr = cb;
            }
            
            BaaSCallback fnPtr;
        } CallbackWrapper;
        
        void configDeveloperInfo(TBaaSInfo devInfo);
        
        void signUp(std::map<std::string, std::string> userInfo, BaaSCallback& cb);
        
        void login(const std::string& username, const std::string& password, BaaSCallback& cb);
        void logout(BaaSCallback& cb);
        
        bool isLoggedIn();
        
        std::string getUserID();
        
        void saveObjectInBackground(const std::string& className, const std::string& json, BaaSCallback& cb);
        
        const char* saveObject(const std::string& className, const std::string& json);

        void getObjectInBackground(const std::string& className, const std::string& objId, BaaSCallback& cb);
        void getObjectsInBackground(const std::string& className, const std::vector<std::string>& objIds, BaaSCallback& cb);

        void findObjectInBackground(const std::string& className, const std::string& key, const std::string value, BaaSCallback& cb);
        void findObjectsInBackground(const std::string& className, const std::string& key, const std::vector<std::string>& values, BaaSCallback& cb);
        
        const char* getObject(const std::string& className, const std::string& objId);
        

        void updateObjectInBackground(const std::string& className, const std::string& objId, const std::string& jSonChanges, BaaSCallback& cb);
        const char* updateObject(const std::string& className, const std::string& objId, const std::string& jsonChanges);

        void deleteObjectInBackground(const std::string& className, const std::string& objId, BaaSCallback& cb);
        bool deleteObject(const std::string& className, const std::string& objId);

        /**
         * Return cached config.
         */
        void    fetchConfigInBackground(BaaSCallback& cb);
        bool    getBoolConfig(const std::string& param);
        int     getIntegerConfig(const std::string& param);
        double  getDoubleConfig(const std::string& param);
        long    getLongConfig(const std::string& param);
        const char* getStringConfig(const std::string& param);
        const char* getArrayConfig(const std::string& param);

        /**
         @brief set login callback function
         */
        inline void setCallback(const BaaSCallback &cb)
        {
            _callback = cb;
        }

        /**
         @brief get login callback function
         */
        inline BaaSCallback& getCallback()
        {
            return _callback;
        }
    protected:
        BaaSCallback _callback;
    };
}}

#endif
