//
//  ProtocolData.h
//  PluginProtocol
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 zhangbin. All rights reserved.
//

#ifndef __CCX_PROTOCOL_DATA_H__
#define __CCX_PROTOCOL_DATA_H__

#include "PluginProtocol.h"
#include <string>
#include <functional>

namespace cocos2d { namespace plugin {
    
    enum DataActionResultCode {
        kOpenSucceed,
        kOpenConflicting,
        kOpenFailed,
        
        kResolveSucceed,
        kResolveFailed,
        
        kReadSucceed,
        kReadFailed,
        
        kWriteSucceed,
        kWriteFailed,
    };
    
    enum DataConflictPolicy {
        kConflictPolicyManual,
        kConflictPolicyLongestPlaytime,
        kConflictPolicyLastKnownGood,
        kConflictPolicyMostRecentlyModified,
        kConflictPolicyHighestProgress,
    };
    
    class ProtocolData;
    class DataActionListener {
    public:
        virtual void onDataActionResult(ProtocolData* pPlugin, int code, void* data, size_t length) = 0;
    };
    
    typedef std::map<std::string, std::string> TDataDeveloperInfo;
    
    class ProtocolData : public PluginProtocol
    {
    public:
        ProtocolData();
        virtual ~ProtocolData();
        
        typedef std::function<void(int, void*, int64_t)> ProtocolDataCallback;
        
        /**
         @brief config the application info
         @param devInfo This parameter is the info of aplication,
         different plugin have different format
         @warning Must invoke this interface before other interfaces.
         And invoked only once.
         */
        void configDeveloperInfo(TDataDeveloperInfo devInfo);
        void openData(const std::string& fileName, DataConflictPolicy policy);
        void readCurrentData();
        void resolveConflict(const std::string& conflictId, void* data, long length, std::map<std::string, std::string>& changes);
        void commitData(void* data, long length, const char* imagePath, const std::string& description);

        /*
         @deprecated
         @brief set callback function
         */
        CC_DEPRECATED_ATTRIBUTE inline void setActionListener(DataActionListener* listener)
        {
            _listener = listener;
        }
        /*
         @deprecated
         @brief get login callback function
         */
        CC_DEPRECATED_ATTRIBUTE inline DataActionListener* getActionListener()
        {
            return _listener;
        }
        
        /**
         @brief set login callback function
         */
        inline void setCallback(const ProtocolDataCallback &cb)
        {
            _callback = cb;
        }
        
        /**
         @brief get login callback function
         */
        inline ProtocolDataCallback& getCallback()
        {
            return _callback;
        }
        
    protected:
        DataActionListener* _listener;
        ProtocolDataCallback _callback;
    };
    
}} // namespace cocos2d { namespace plugin {

#endif
