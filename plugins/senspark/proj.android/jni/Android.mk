LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

$(call import-add-path,$(LOCAL_PATH)/../../../..)

LOCAL_MODULE := PluginSensparkStatic

LOCAL_MODULE_FILENAME := libPluginSensparkStatic

LOCAL_SRC_FILES :=\
$(addprefix ../../platform/android/, \
	AdColonyProtocolAds.cpp \
    AdmobProtocolAds.cpp \
    ChartboostProtocolAds.cpp \
    FacebookProtocolAds.cpp \
    FacebookProtocolShare.cpp \
    FacebookProtocolSocial.cpp \
    FacebookProtocolUser.cpp \
    FlurryProtocolAds.cpp \
    FlurryProtocolAnalytics.cpp \
    GooglePlayProtocolData.cpp \
    GooglePlayProtocolSocial.cpp \
    GooglePlayProtocolUser.cpp \
    GoogleProtocolAnalytics.cpp \
    GooglePlusProtocolUser.cpp \
    GooglePlusProtocolShare.cpp \
    ParseProtocolBaaS.cpp \
) \
../../classes/SensparkPluginManager.cpp

LOCAL_CFLAGS := -std=c++11 -Wno-psabi
LOCAL_EXPORT_CFLAGS := -Wno-psabi

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include 
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../platform/android

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../include 
LOCAL_EXPORT_C_INCLUDES += $(LOCAL_PATH)/../../platform/android

LOCAL_LDLIBS := -landroid
LOCAL_LDLIBS += -llog

LOCAL_STATIC_LIBRARIES := android_native_app_glue
LOCAL_STATIC_LIBRARIES += PluginProtocolStatic

include $(BUILD_STATIC_LIBRARY)

$(call import-module,android/native_app_glue)
$(call import-module,protocols/proj.android/jni)
