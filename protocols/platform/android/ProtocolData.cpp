//
//  GooglePlayProtocolData.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 8/10/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#include "ProtocolData.h"
#include "PluginJniHelper.h"
#include <android/log.h>
#include "PluginUtils.h"
#include "PluginJavaData.h"

namespace cocos2d { namespace plugin {

extern "C" {

JNIEXPORT void JNICALL Java_org_cocos2dx_plugin_DataWrapper_nativeOnDataResult(JNIEnv*  env, jobject thiz, jstring className, jint ret, jbyteArray data)
{
    std::string strClassName = PluginJniHelper::jstring2string(env, className);

    jbyte* bufferPtr = nullptr;
    jsize len = 0;
    if (data != nullptr) {
        bufferPtr = env->GetByteArrayElements(data, nullptr);
        len = env->GetArrayLength(data);
    }

    PluginProtocol* pPlugin = PluginUtils::getPluginPtr(strClassName);
    PluginUtils::outputLog("ProtocolData", "nativeOnDataResult(), Get plugin ptr : %p", pPlugin);
    if (pPlugin != NULL)
    {
        PluginUtils::outputLog("ProtocolData", "nativeOnDataResult(), Get plugin name : %s", pPlugin->getPluginName());
        ProtocolData* pData = dynamic_cast<ProtocolData*>(pPlugin);
        if (pData != NULL)
        {
            DataActionListener* listener = pData->getActionListener();
            if (NULL != listener)
            {
                listener->onDataActionResult(pData, ret, bufferPtr, len);
            }
            else
            {
                ProtocolData::ProtocolDataCallback callback = pData->getCallback();
                if(callback)
                {
                    callback(ret, bufferPtr, len);
                }
                else
                {
                    PluginUtils::outputLog("Listener of plugin %s not set correctly", pPlugin->getPluginName());
                }
            }
        }
    }
}

}

    ProtocolData::ProtocolData()
    : _listener(NULL)
    {
    }

    ProtocolData::~ProtocolData()
    {
    }

    void ProtocolData::configDeveloperInfo(TDataDeveloperInfo devInfo)
    {
        if (devInfo.empty())
        {
            PluginUtils::outputLog("ProtocolData", "The developer info is empty for %s!", this->getPluginName());
            return;
        }
        else
        {
            PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
            PluginJniMethodInfo t;
            if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "configDeveloperInfo", "(Ljava/util/Hashtable;)V")) {
                jobject obj_map = PluginUtils::createJavaMapObject(&devInfo);

                t.env->CallVoidMethod(pData->jobj, t.methodID, obj_map);
                t.env->DeleteLocalRef(obj_map);
                t.env->DeleteLocalRef(t.classID);
            }
        }
    }

    void ProtocolData::openData(const std::string &fileName, cocos2d::plugin::DataConflictPolicy policy) {
        PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
        PluginJniMethodInfo t;
        if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "openData", "(Ljava/lang/String;I)V")) {
            jstring file_name = t.env->NewStringUTF(fileName.c_str());

            t.env->CallVoidMethod(pData->jobj, t.methodID, file_name, policy);

            t.env->DeleteLocalRef(file_name);
            t.env->DeleteLocalRef(t.classID);
        }
    }

    void ProtocolData::readCurrentData() {
        PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
        PluginJniMethodInfo t;

        if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "readCurrentData", "()V")) {
           t.env->CallVoidMethod(pData->jobj, t.methodID);

           t.env->DeleteLocalRef(t.classID);
        }
    }

    void ProtocolData::resolveConflict(const std::string& conflictId, void* data, long length, std::map<std::string, std::string>& changes) {
        PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
        PluginJniMethodInfo t;

        if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "resolveConflict", "(Ljava/lang/String;[BLjava/util/Hashtable;)V")) {
           jstring conflict_id = t.env->NewStringUTF(conflictId.c_str());
           jbyteArray arr = t.env->NewByteArray(length);
           t.env->SetByteArrayRegion(arr, 0, length, (jbyte*)data);

           jobject obj_changes = PluginUtils::createJavaMapObject(&changes);

           t.env->CallVoidMethod(pData->jobj, t.methodID, conflict_id, arr, obj_changes);

           t.env->DeleteLocalRef(obj_changes);
           t.env->DeleteLocalRef(conflict_id);
           t.env->DeleteLocalRef(arr);
           t.env->DeleteLocalRef(t.classID);
        }
    }

    void ProtocolData::commitData(void *data, long length, const char *imagePath, const std::string &description) {
        PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
        PluginJniMethodInfo t;

        if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "commitData", "([BLjava/lang/String;Ljava/lang/String;)V")) {
           jbyteArray arr = t.env->NewByteArray(length);
           t.env->SetByteArrayRegion(arr, 0, length, (jbyte*)data);

           jstring image_path = nullptr;
           if (imagePath) {
               image_path = t.env->NewStringUTF(imagePath);
           }

           jstring desc = t.env->NewStringUTF(description.c_str());

           t.env->CallVoidMethod(pData->jobj, t.methodID, arr, image_path, desc);

           if (image_path) {
               t.env->DeleteLocalRef(image_path);
           }
           t.env->DeleteLocalRef(desc);
           t.env->DeleteLocalRef(arr);
           t.env->DeleteLocalRef(t.classID);
        }
    }
}} // namespace cocos2d { namespace plugin {
