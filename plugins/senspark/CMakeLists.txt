cmake_minimum_required(VERSION 3.1)

project(plugin_senspark)

include_directories(
    include
    include/senspark
)

set(LIB_SRC
    classes/SensparkPluginManager.cpp
    classes/AdMobProtocolAdsImpl.cpp
    classes/GoogleProtocolAnalyticsImpl.cpp
    platform/android/GooglePlusProtocolUser.cpp
    platform/android/GooglePlayProtocolData.cpp
    platform/android/FacebookProtocolSocial.cpp
    platform/android/FacebookProtocolAds.cpp
    platform/android/FlurryProtocolAds.cpp
    platform/android/AdColonyProtocolAds.cpp
    platform/android/FlurryProtocolAnalytics.cpp
    platform/android/FacebookProtocolUser.cpp
    platform/android/GoogleProtocolAnalytics.cpp
    platform/android/ParseProtocolBaaS.cpp
    platform/android/AdmobProtocolAds.cpp
    platform/android/ChartboostProtocolAds.cpp
    platform/android/UnityProtocolAds.cpp
    platform/android/GooglePlayProtocolSocial.cpp
    platform/android/GooglePlusProtocolShare.cpp
    platform/android/BaasboxProtocolBaaS.cpp
    platform/android/GooglePlayProtocolUser.cpp
    platform/android/FacebookProtocolShare.cpp
)

set(LIB_HEADERS
    include/FacebookProtocolAds.h
    include/VungleProtocolAds.h
    include/ChartboostProtocolAds.h
    include/FacebookProtocolSocial.h
    include/GooglePlusProtocolUser.h
    include/GameCenterProtocolSocial.h
    include/GooglePlayProtocolData.h
    include/SensparkPluginMacros.h
    include/FacebookProtocolShare.h
    include/FacebookProtocolUser.h
    include/GooglePlusProtocolShare.h
    include/FlurryProtocolAnalytics.h
    include/GooglePlayProtocolSocial.h
    include/GooglePlayProtocolUser.h
    include/BaasboxProtocolBaaS.h
    include/UnityProtocolAds.h
    include/AdmobProtocolAds.h
    include/ParseProtocolBaaS.h
    include/AdColonyProtocolAds.h
    include/GoogleProtocolAnalytics.h
    include/SensparkPlugin.h
    include/GameCenterProtocolUser.h
    include/FlurryProtocolAds.h
    include/senspark/SensparkPluginFwd.hpp
    include/SensparkPluginManager.h
)

add_library(${PROJECT_NAME} STATIC ${LIB_SRC} ${LIB_HEADERS})

target_link_libraries(${PROJECT_NAME} plugin_protocols)

target_include_directories(${PROJECT_NAME} PUBLIC
    include
    include/senspark
)