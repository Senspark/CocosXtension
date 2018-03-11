LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := PluginProtocolStatic

LOCAL_MODULE_FILENAME := libPluginProtocolStatic

LOCAL_SRC_FILES :=\
$(addprefix ../../platform/android/, \
	PluginFactory.cpp \
    PluginJniHelper.cpp \
    PluginUtils.cpp \
    PluginProtocol.cpp \
    ProtocolAnalytics.cpp \
    ProtocolBaaS.cpp \
    ProtocolIAP.cpp \
    ProtocolAds.cpp \
    ProtocolData.cpp \
    ProtocolShare.cpp \
    ProtocolUser.cpp \
    ProtocolSocial.cpp \
    ProtocolPlatform.cpp \
    AgentManager.cpp \
) \
../../PluginManager.cpp \
../../PluginParam.cpp

LOCAL_CFLAGS := -std=c++11

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../platform/android

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../include
LOCAL_EXPORT_C_INCLUDES += $(LOCAL_PATH)/../../platform/android

include $(BUILD_STATIC_LIBRARY)
