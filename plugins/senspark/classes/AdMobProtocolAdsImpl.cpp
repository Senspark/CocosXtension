//
//  AdMobProtocolAds.cpp
//  PluginSenspark
//
//  Created by enrevol on 4/8/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#include "../include/AdMobProtocolAds.h"

NS_SENSPARK_PLUGIN_ADS_BEGIN
AdmobProtocolAds::AdType::operator std::string() const { return _s; }
AdmobProtocolAds::AdType::AdType(const std::string& s) : _s(s) {}

AdmobProtocolAds::AdSize::operator std::string() const { return _s; }
AdmobProtocolAds::AdSize::AdSize(const std::string& s) : _s(s) {}

const AdmobProtocolAds::AdType AdmobProtocolAds::AdType::Banner("1");
const AdmobProtocolAds::AdType AdmobProtocolAds::AdType::Interstitial("2");

const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Banner("0");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::LargeBanner("1");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::MediumRectangle("2");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::FullBanner("3");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Leaderboard("4");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Skyscraper("5");
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::SmartBanner("6");

const std::string AdmobProtocolAds::AdIdKey("AdmobID");
const std::string AdmobProtocolAds::AdTypeKey("AdmobType");
const std::string AdmobProtocolAds::AdSizeKey("AdmobSizeEnum");

AdmobProtocolAds::AdmobProtocolAds() = default;

void AdmobProtocolAds::configureAds(const std::string& adsId) {
    cocos2d::plugin::TAdsInfo devInfo;
    devInfo[AdIdKey] = adsId;
    configDeveloperInfo(devInfo);
}

void AdmobProtocolAds::addTestDevice(const std::string &deviceId) {
    cocos2d::plugin::PluginParam deviceIdParam(deviceId.c_str());
    callFuncWithParam("addTestDevice", &deviceIdParam, nullptr);
}

void AdmobProtocolAds::showBannerAd(const std::string& bannerAdId,
                                    AdSize bannerAdSize,
                                    AdsPos bannerAdPosition) {
    configureAds(bannerAdId);
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

void AdmobProtocolAds::slideBannerUp() {
    callFuncWithParam("slideUpBannerAds", nullptr);
}

void AdmobProtocolAds::slideBannerDown() {
    callFuncWithParam("slideDownBannerAds", nullptr);
}

int AdmobProtocolAds::getBannerWidthInPixel() {
    return callIntFuncWithParam("getBannerWidthInPixel", nullptr);
}

int AdmobProtocolAds::getBannerHeightInPixel() {
    return callIntFuncWithParam("getBannerHeightInPixel", nullptr);
}
NS_SENSPARK_PLUGIN_ADS_END