//
//  AdMobProtocolAds.cpp
//  PluginSenspark
//
//  Created by enrevol on 4/8/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#include <array>
#include <unordered_map>

#include "../include/AdMobProtocolAds.h"
#include "senspark/utility.hpp"

NS_SENSPARK_PLUGIN_ADS_BEGIN
namespace {

/// AdmobProtocolAds is actually ProtocolAds, so we can not store member
/// variable in it.
struct AdMobData {
    std::pair<int, int> bannerAdSize_;
    std::pair<int, int> nativeExpressAdSize_;

    /// Backward compability.
    std::string bannerAdId_;
};

std::unordered_map<AdmobProtocolAds*, AdMobData> data_;

/// Use this for workaround.
void removeData(AdmobProtocolAds* instance) { data_.erase(instance); }

AdMobData& getData(AdmobProtocolAds* instance) { return data_[instance]; }
} // namespace

AdmobProtocolAds::AdType::AdType(const std::string& s)
    : _s(s) {}

AdmobProtocolAds::AdType::operator const std::string&() const {
    return getDescription();
}

const std::string& AdmobProtocolAds::AdType::getDescription() const {
    return _s;
}

AdmobProtocolAds::AdSize::AdSize(const std::string& s, int w, int h)
    : _s(s)
    , _w(w)
    , _h(h) {}

AdmobProtocolAds::AdSize::operator const std::string&() const {
    return getDescription();
}

const std::string& AdmobProtocolAds::AdSize::getDescription() const {
    return _s;
}

const AdmobProtocolAds::AdType AdmobProtocolAds::AdType::Banner("1");
const AdmobProtocolAds::AdType AdmobProtocolAds::AdType::Interstitial("2");

// clang-format off
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Banner("0", 320, 50);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::LargeBanner("1", 320, 100);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::MediumRectangle("2", 320, 250);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::FullBanner("3", 468, 60);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Leaderboard("4", 728, 90);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Skyscraper("5", 120, 600);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::SmartBanner("6", -1, -2);
// clang-format on

const std::string AdmobProtocolAds::AdBannerIdKey("AdmobID");
const std::string AdmobProtocolAds::AdInterstitialIdKey("AdmobInterstitialID");
const std::string AdmobProtocolAds::AdTypeKey("AdmobType");
const std::string AdmobProtocolAds::AdSizeKey("AdmobSizeEnum");

AdmobProtocolAds::AdmobProtocolAds() = default;

AdmobProtocolAds::~AdmobProtocolAds() {
    // This method won't be called.
    // Maybe memory leak if many admob protocols are used.
}

void AdmobProtocolAds::configureAds(const std::string& adsId) {
    cocos2d::plugin::TAdsInfo devInfo;
    devInfo[AdBannerIdKey] = adsId;
    getData(this).bannerAdId_ = adsId;
    configDeveloperInfo(devInfo);
}

void AdmobProtocolAds::configureAds(const std::string& bannerAds,
                                    const std::string& interstitialAds) {
    cocos2d::plugin::TAdsInfo devInfo;
    devInfo[AdBannerIdKey] = bannerAds;
    devInfo[AdInterstitialIdKey] = interstitialAds;
    getData(this).bannerAdId_ = bannerAds;
    configDeveloperInfo(devInfo);
}

void AdmobProtocolAds::addTestDevice(const std::string& deviceId) {
    callFunction(this, "addTestDevice", deviceId.c_str());
}

void AdmobProtocolAds::configMediationAdColony(
    const cocos2d::plugin::TAdsInfo& params) {
    callFunction(this, "configMediationAdColony", params);
}

void AdmobProtocolAds::showAds(cocos2d::plugin::TAdsInfo info, AdsPos pos) {
    auto adType = info[AdTypeKey];
    if (adType == AdType::Banner.getDescription()) {
        auto _adSize = info[AdSizeKey];
        auto adSize = std::stoi(_adSize);
        const std::array<AdSize, 7> AdSizes = {
            {AdSize::Banner, AdSize::LargeBanner, AdSize::MediumRectangle,
             AdSize::FullBanner, AdSize::Leaderboard, AdSize::Skyscraper,
             AdSize::SmartBanner}};
        showBannerAd(getData(this).bannerAdId_, AdSizes.at(adSize), pos);
    } else {
        showInterstitialAd();
    }
}

void AdmobProtocolAds::showBannerAd(const std::string& bannerAdId,
                                    AdSize bannerAdSize,
                                    AdsPos bannerAdPosition) {
    showBannerAd(bannerAdId, bannerAdSize._w, bannerAdSize._h);
    moveBannerAd(bannerAdPosition);
}

void AdmobProtocolAds::showBannerAd(const std::string& bannerAdId, int width,
                                    int height) {
    callFunction(this, "showBannerAd", bannerAdId.c_str(), width, height);
    getData(this).bannerAdSize_ = std::make_pair(width, height);
    getData(this).bannerAdId_ = bannerAdId;
}

void AdmobProtocolAds::hideBannerAd() { callFunction(this, "hideBannerAd"); }

void AdmobProtocolAds::moveBannerAd(AdsPos position) {
    int x;
    int y;
    std::tie(x, y) =
        computeAdViewPosition(position, getData(this).bannerAdSize_.first,
                              getData(this).bannerAdSize_.second);
    moveBannerAd(x, y);
}

void AdmobProtocolAds::moveBannerAd(int x, int y) {
    callFunction(this, "moveBannerAd", x, y);
}

void AdmobProtocolAds::showNativeExpressAd(const std::string& adUnitId,
                                           int width, int height,
                                           AdsPos position) {
    showNativeExpressAd(adUnitId, width, height);
    moveNativeExpressAd(position);
}

void AdmobProtocolAds::showNativeExpressAd(const std::string& adUnitId,
                                           int width, int height, int x,
                                           int y) {
    showNativeExpressAd(adUnitId, width, height);
    moveNativeExpressAd(x, y);
}

void AdmobProtocolAds::showNativeExpressAd(const std::string& adUnitId,
                                           int width, int height) {
    callFunction(this, "showNativeExpressAd", adUnitId.c_str(), width, height);
    getData(this).nativeExpressAdSize_ = std::make_pair(width, height);
}

void AdmobProtocolAds::hideNativeExpressAd() {
    callFunction(this, "hideNativeExpressAd");
}

void AdmobProtocolAds::moveNativeExpressAd(AdsPos position) {
    int x;
    int y;
    std::tie(x, y) = computeAdViewPosition(
        position, getData(this).nativeExpressAdSize_.first,
        getData(this).nativeExpressAdSize_.second);
    moveNativeExpressAd(x, y);
}

void AdmobProtocolAds::moveNativeExpressAd(int x, int y) {
    callFunction(this, "moveNativeExpressAd", x, y);
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

int AdmobProtocolAds::getBannerWidthInPixels() {
    return callFunction<int>(this, "getBannerWidthInPixels");
}

int AdmobProtocolAds::getBannerHeightInPixels() {
    return callFunction<int>(this, "getBannerHeightInPixels");
}

int AdmobProtocolAds::getSizeInPixels(int size) {
    return callFunction<int>(this, "getSizeInPixels", size);
}

std::pair<int, int> AdmobProtocolAds::computeAdViewPosition(AdsPos position,
                                                            int width,
                                                            int height) {
    int screenWidth = callFunction<int>(this, "getRealScreenWidthInPixels");
    int screenHeight = callFunction<int>(this, "getRealScreenHeightInPixels");
    int viewWidth = getSizeInPixels(width);
    int viewHeight = getSizeInPixels(height);
    int x = 0;
    int y = 0;
    switch (position) {
    case AdsPos::kPosTop:
        x = (screenWidth - viewWidth) / 2;
        break;
    case AdsPos::kPosTopLeft:
        break;
    case AdsPos::kPosTopRight:
        x = screenWidth - viewWidth;
        break;
    case AdsPos::kPosBottom:
        x = (screenWidth - viewWidth) / 2;
        y = screenHeight - viewHeight;
        break;
    case AdsPos::kPosBottomLeft:
        y = screenHeight - viewHeight;
        break;
    case AdsPos::kPosBottomRight:
        x = screenWidth - viewWidth;
        y = screenHeight - viewHeight;
        break;
    case AdsPos::kPosCenter:
        x = (screenWidth - viewWidth) / 2;
        y = (screenHeight - viewHeight) / 2;
        break;
    }
    return std::make_pair(x, y);
}
NS_SENSPARK_PLUGIN_ADS_END
