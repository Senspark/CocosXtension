//
//  AdMobProtocolAds.cpp
//  PluginSenspark
//
//  Created by enrevol on 4/8/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#include <unordered_map>

#include "../include/AdMobProtocolAds.h"

NS_SENSPARK_PLUGIN_ADS_BEGIN
AdmobProtocolAds::AdType::AdType(const std::string& s)
    : _s(s) {}

AdmobProtocolAds::AdType::operator const std::string&() const {
    return getDescription();
}

const std::string& AdmobProtocolAds::AdType::getDescription() const {
    return _s;
}

AdmobProtocolAds::AdSize::AdSize(const std::string& s)
    : _s(s) {}

AdmobProtocolAds::AdSize::operator const std::string&() const {
    return getDescription();
}

const std::string& AdmobProtocolAds::AdSize::getDescription() const {
    return _s;
}

const AdmobProtocolAds::AdType AdmobProtocolAds::AdType::Banner("1");
const AdmobProtocolAds::AdType AdmobProtocolAds::AdType::Interstitial("2");

const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Banner("0");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::LargeBanner("1");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::MediumRectangle("2");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::FullBanner("3");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Leaderboard("4");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Skyscraper("5");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::SmartBanner("6");

const std::string AdmobProtocolAds::AdBannerIdKey("AdmobID");
const std::string AdmobProtocolAds::AdInterstitialIdKey("AdmobInterstitialID");
const std::string AdmobProtocolAds::AdTypeKey("AdmobType");
const std::string AdmobProtocolAds::AdSizeKey("AdmobSizeEnum");

AdmobProtocolAds::AdmobProtocolAds() = default;

void AdmobProtocolAds::configureAds(const std::string& adsId) {
    cocos2d::plugin::TAdsInfo devInfo;
    devInfo[AdBannerIdKey] = adsId;
    configDeveloperInfo(devInfo);
}

void AdmobProtocolAds::configureAds(const std::string &bannerAds, const std::string &interstitialAds) {
    cocos2d::plugin::TAdsInfo devInfo;
    devInfo[AdBannerIdKey]          = bannerAds;
    devInfo[AdInterstitialIdKey]    = interstitialAds;
    configDeveloperInfo(devInfo);
}

void AdmobProtocolAds::addTestDevice(const std::string &deviceId) {
    cocos2d::plugin::PluginParam deviceIdParam(deviceId.c_str());
    callFuncWithParam("addTestDevice", &deviceIdParam, nullptr);
}

void AdmobProtocolAds::showBannerAd(const std::string& bannerAdId,
                                    AdSize bannerAdSize,
                                    AdsPos bannerAdPosition) {
    cocos2d::plugin::TAdsInfo info;
    info[AdTypeKey] = AdType::Banner;
    info[AdSizeKey] = bannerAdSize;
    showAds(info, bannerAdPosition);
}

void AdmobProtocolAds::hideBannerAd() {
    cocos2d::plugin::TAdsInfo info;
    info[AdTypeKey] = AdType::Banner;
    hideAds(info);
}

void AdmobProtocolAds::showInterstitialAd() {
    callFuncWithParam("showInterstitial", nullptr);
}

void AdmobProtocolAds::showInterstitialAd(const std::string& interstitialAdId) {
    configureAds(interstitialAdId);
    cocos2d::plugin::TAdsInfo info;
    info[AdTypeKey] = AdType::Interstitial;
    showAds(info);
}

void AdmobProtocolAds::showInterstitialAd(const std::string& interstitialAdId,
                                          const AdsCallback& iapCallback) {
    showInterstitialAd(interstitialAdId);
    setCallback(iapCallback);
}

void AdmobProtocolAds::loadInterstitial() {
    callFuncWithParam("loadInterstitial", nullptr);
}

bool AdmobProtocolAds::hasInterstitial() {
    return callBoolFuncWithParam("hasInterstitial", nullptr);
}

void AdmobProtocolAds::showNativeExpressAd(const std::string& adUnitId,
                                           int width, int height,
                                           AdsPos position) {
    using cocos2d::plugin::PluginParam;
    PluginParam param0{adUnitId.c_str()};
    PluginParam param1{width};
    PluginParam param2{height};
    PluginParam param3{position};
    callFuncWithParam("showNativeExpressAd", &param0, &param1, &param2, &param3,
                      nullptr);
}

void AdmobProtocolAds::hideNativeExpressAd() {
    callFuncWithParam("hideNativeExpressAd", nullptr);
}

int AdmobProtocolAds::getSizeInPixels(int size) {
    using cocos2d::plugin::PluginParam;
    PluginParam param{size};
    return callIntFuncWithParam("getSizeInPixels", &param, nullptr);
}

void AdmobProtocolAds::slideBannerUp() {
    callFuncWithParam("slideBannerUp", nullptr);
}

void AdmobProtocolAds::slideBannerDown() {
    callFuncWithParam("slideBannerDown", nullptr);
}

int AdmobProtocolAds::getBannerWidthInPixel() {
    return callIntFuncWithParam("getBannerWidthInPixel", nullptr);
}

int AdmobProtocolAds::getBannerHeightInPixel() {
    return callIntFuncWithParam("getBannerHeightInPixel", nullptr);
}

void AdmobProtocolAds::loadRewardedAd(const std::string& adID) {
    cocos2d::plugin::PluginParam param(adID.c_str());
    callFuncWithParam("loadRewardedAd", &param, nullptr);
}

void AdmobProtocolAds::showRewardedAd() {
    callFuncWithParam("showRewardedAd", nullptr);
}

bool AdmobProtocolAds::hasRewardedAd() {
    return callBoolFuncWithParam("hasRewardedAd", nullptr);
}

void AdmobProtocolAds::initializeMediationAd() {
    callFuncWithParam("initializeMediationAd", nullptr);
}

void AdmobProtocolAds::configMediationAdColony(const cocos2d::plugin::TAdsInfo &params) {
    cocos2d::plugin::PluginParam pParam(params);
    callFuncWithParam("configMediationAdColony", &pParam, nullptr);
}

void AdmobProtocolAds::configMediationAdUnity(const cocos2d::plugin::TAdsInfo &params) {
    cocos2d::plugin::PluginParam pParam(params);
    callFuncWithParam("configMediationAdUnity", &pParam, nullptr);
}

void AdmobProtocolAds::configMediationAdVungle(const cocos2d::plugin::TAdsInfo &params) {
    cocos2d::plugin::PluginParam pParam(params);
    callFuncWithParam("configMediationAdVungle", &pParam, nullptr);
}

NS_SENSPARK_PLUGIN_ADS_END