//
//  AdMobProtocolAds.cpp
//  PluginSenspark
//
//  Created by enrevol on 4/8/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#include <unordered_map>

#include "../include/AdMobProtocolAds.h"
#include "senspark/utility.hpp"

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

void AdmobProtocolAds::configureAds(const std::string& bannerAds,
                                    const std::string& interstitialAds) {
    cocos2d::plugin::TAdsInfo devInfo;
    devInfo[AdBannerIdKey] = bannerAds;
    devInfo[AdInterstitialIdKey] = interstitialAds;
    configDeveloperInfo(devInfo);
}

void AdmobProtocolAds::addTestDevice(const std::string& deviceId) {
    callFunction(this, "addTestDevice", deviceId.c_str());
}

void AdmobProtocolAds::configMediationAdColony(
    const cocos2d::plugin::TAdsInfo& params) {
    callFunction(this, "configMediationAdColony", params);
}

void AdmobProtocolAds::showBannerAd(const std::string& bannerAdId,
                                    AdSize bannerAdSize,
                                    AdsPos bannerAdPosition) {
    callFunction(this, "showBannerAd", bannerAdId.c_str(),
                 std::stoi(bannerAdSize.getDescription()), bannerAdPosition);
}

void AdmobProtocolAds::hideBannerAd() { callFunction(this, "hideBannerAd"); }

void AdmobProtocolAds::showNativeExpressAd(const std::string& adUnitId,
                                           int width, int height,
                                           AdsPos position) {
    callFunction(this, "showNativeExpressAd", adUnitId.c_str(), width, height,
                 position);
}

void AdmobProtocolAds::showNativeExpressAd(const std::string& adUnitId,
                                           int width, int height, int x,
                                           int y) {
    callFunction(this, "showNativeExpressAd", adUnitId.c_str(), width, height,
                 x, y);
}

void AdmobProtocolAds::hideNativeExpressAd() {
    callFunction(this, "hideNativeExpressAd");
}

void AdmobProtocolAds::showInterstitialAd() {
    callFunction(this, "showInterstitialAd");
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
    callFunction(this, "loadInterstitial");
}

void AdmobProtocolAds::loadInterstitialAd(const std::string& adId) {
    callFunction(this, "loadInterstitialAd", adId.c_str());
}

bool AdmobProtocolAds::hasInterstitialAd() {
    return callFunction<bool>(this, "hasInterstitialAd");
}

void AdmobProtocolAds::showRewardedAd() {
    callFunction(this, "showRewardedAd");
}

void AdmobProtocolAds::loadRewardedAd(const std::string& adId) {
    callFunction(this, "loadRewardedAd", adId.c_str());
}

bool AdmobProtocolAds::hasRewardedAd() {
    return callFunction<bool>(this, "hasRewardedAd");
}

void AdmobProtocolAds::slideUpBannerAd() {
    callFunction(this, "slideUpBannerAd");
}

void AdmobProtocolAds::slideDownBannerAd() {
    callFunction(this, "slideDownBannerAd");
}

int AdmobProtocolAds::getSizeInPixels(int size) {
    return callFunction<int>(this, "getSizeInPixels", size);
}

int AdmobProtocolAds::getBannerWidthInPixels() {
    return callFunction<int>(this, "getBannerWidthInPixels");
}

int AdmobProtocolAds::getBannerHeightInPixels() {
    return callFunction<int>(this, "getBannerHeightInPixels");
}
NS_SENSPARK_PLUGIN_ADS_END
