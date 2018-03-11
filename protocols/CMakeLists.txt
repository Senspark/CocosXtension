cmake_minimum_required(VERSION 3.1)

project(plugin_protocols)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-psabi")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++1z")

include_directories(
    include
)

set(LIB_SRC
    PluginParam.cpp
    PluginManager.cpp
    platform/android/ProtocolAnalytics.cpp
    platform/android/ProtocolUser.cpp
    platform/android/AgentManager.cpp
    platform/android/ProtocolSocial.cpp
    platform/android/ProtocolPlatform.cpp
    platform/android/PluginJniHelper.cpp
    platform/android/ProtocolAds.cpp
    platform/android/ProtocolIAP.cpp
    platform/android/PluginUtils.cpp
    platform/android/PluginProtocol.cpp
    platform/android/ProtocolShare.cpp
    platform/android/ProtocolBaaS.cpp
    platform/android/ProtocolData.cpp
    platform/android/PluginFactory.cpp
    src/senspark/utility.cpp
)

set(LIB_HEADERS
    include/senspark/utility.hpp
    include/senspark/integer_sequence.hpp
    include/ProtocolData.h
    include/ProtocolShare.h
    include/PluginProtocol.h
    include/ProtocolIAP.h
    include/PluginFactory.h
    include/ProtocolSocial.h
    include/AgentManager.h
    include/iOSIAPAgent.h
    include/PluginParam.h
    include/ProtocolAnalytics.h
    include/PluginManager.h
    include/ProtocolUser.h
    include/ProtocolPlatform.h
    include/ProtocolAds.h
    include/ProtocolBaaS.h
    platform/ios/InterfaceShare.h
    platform/ios/PluginOCMacros.h
    platform/ios/PluginUtilsIOS.h
    platform/ios/ShareWrapper.h
    platform/ios/InterfaceIAP.h
    platform/ios/InterfaceSocial.h
    platform/ios/InterfaceBaaS.h
    platform/ios/BaaSWrapper.h
    platform/ios/InterfaceUser.h
    platform/ios/DataWrapper.h
    platform/ios/InterfaceAds.h
    platform/ios/InterfaceData.h
    platform/ios/AdsWrapper.h
    platform/ios/UserWrapper.h
    platform/ios/ParseUtils.h
    platform/ios/IAPWrapper.h
    platform/ios/SocialWrapper.h
    platform/ios/EReachability.h
    platform/ios/InterfaceAnalytics.h
    platform/android/PluginUtils.h
    platform/android/PluginJniHelper.h
    platform/android/PluginJavaData.h
    platform/android/PluginJniMacros.h
)

add_library(${PROJECT_NAME} STATIC ${LIB_SRC} ${LIB_HEADERS})

target_include_directories(${PROJECT_NAME} PUBLIC
    include
    include/senspark
    platform/android
)
