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

#define BOOLSTR(X) (X ? "true" : "false")

NS_SENSPARK_PLUGIN_ADS_BEGIN
namespace {

/// AdmobProtocolAds is actually ProtocolAds, so we can not store member
/// variable in it.
struct AdMobData {
    std::unordered_map<std::string, std::pair<int, int>> adSizes_;

    /// Backward compability.
    std::pair<int, int> bannerAdSize_;
    std::pair<int, int> nativeExpressAdSize_;
    std::string bannerAdId_;
    std::string nativeExpressAdId_;
};

std::unordered_map<AdmobProtocolAds*, AdMobData> data_;

/// Use this for workaround.
void removeData(AdmobProtocolAds* instance) { data_.erase(instance); }

AdMobData& getData(AdmobProtocolAds* instance) { return data_[instance]; }
} // namespace

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

// clang-format off
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Banner("0", 320, 50);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::LargeBanner("1", 320, 100);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::MediumRectangle("2", 320, 250);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::FullBanner("3", 468, 60);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Leaderboard("4", 728, 90);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::Skyscraper("5", 120, 600);
const AdmobProtocolAds::AdSize AdmobProtocolAds::AdSize::SmartBanner("6", -1, -2);
// clang-format on

AdmobProtocolAds::AdmobProtocolAds() = default;

AdmobProtocolAds::~AdmobProtocolAds() {
    // This method won't be called.
    // Maybe memory leak if many admob protocols are used.
}

void AdmobProtocolAds::initialize(const std::string& applicationId) {
    callFunction(this, "initialize", applicationId.c_str());
}

void AdmobProtocolAds::addTestDevice(const std::string& deviceId) {
    callFunction(this, "addTestDevice", deviceId.c_str());
}

void AdmobProtocolAds::configMediationAdColony(
    const cocos2d::plugin::TAdsInfo& params) {
    callFunction(this, "configMediationAdColony", params);
}

void AdmobProtocolAds::createBannerAd(const std::string& adId, int width,
                                      int height) {
    getData(this).adSizes_.emplace(std::piecewise_construct,
                                   std::forward_as_tuple(adId),
                                   std::forward_as_tuple(width, height));
    callFunction(this, "createBannerAd", adId.c_str(), width, height);
}

void AdmobProtocolAds::createNativeExpressAd(const std::string& adId, int width,
                                             int height) {
    getData(this).adSizes_.emplace(std::piecewise_construct,
                                   std::forward_as_tuple(adId),
                                   std::forward_as_tuple(width, height));
    callFunction(this, "createNativeExpressAd", adId.c_str(), width, height);
}

void AdmobProtocolAds::createNativeAdvancedAd(const std::string& adId, admob::NativeAdAdvancedType type, const std::string& layoutId, int width, int height, const admob::NativeAdAdvancedParam& params) {
    
    getData(this).adSizes_.emplace(std::piecewise_construct, std::forward_as_tuple(adId), std::forward_as_tuple(width, height));
    callFunction(this, "createNativeAdvancedAd", adId.c_str(), (int) type, layoutId.c_str(), width, height, params);
}

void AdmobProtocolAds::destroyAd(const std::string& adId) {
    callFunction(this, "destroyAd", adId.c_str());
    getData(this).adSizes_.erase(adId);
}

void AdmobProtocolAds::showAd(const std::string& adId) {
    callFunction(this, "showAd", adId.c_str());
}

void AdmobProtocolAds::hideAd(const std::string& adId) {
    callFunction(this, "hideAd", adId.c_str());
}

void AdmobProtocolAds::moveAd(const std::string& adId, int x, int y) {
    callFunction(this, "moveAd", adId.c_str(), x, y);
}

void AdmobProtocolAds::moveAd(const std::string& adId, AdsPos position) {
    int width, height;
    std::tie(width, height) = getAdSize(adId);
    int x, y;
    std::tie(x, y) = computeAdViewPosition(position, width, height);
    moveAd(adId, x, y);
}

std::pair<int, int> AdmobProtocolAds::getAdSize(const std::string& adId) {
    auto&& sizes = getData(this).adSizes_;
    if (not sizes.count(adId)) {
        return std::make_pair(0, 0);
    }
    auto&& size = sizes.at(adId);
    return size;
}

std::pair<int, int>
AdmobProtocolAds::getAdSizeInPixels(const std::string& adId) {
    auto size = getAdSize(adId);
    return std::make_pair(getSizeInPixels(size.first),
                          getSizeInPixels(size.second));
}

void AdmobProtocolAds::showBannerAd(const std::string& bannerAdId,
                                    AdSize bannerAdSize,
                                    AdsPos bannerAdPosition) {
    showBannerAd(bannerAdId, bannerAdSize._w, bannerAdSize._h);
    moveBannerAd(bannerAdPosition);
}

void AdmobProtocolAds::showBannerAd(const std::string& bannerAdId, int width,
                                    int height) {
    getData(this).bannerAdSize_ = std::make_pair(width, height);
    getData(this).bannerAdId_ = bannerAdId;
    createBannerAd(bannerAdId, width, height);
    showAd(bannerAdId);
}

void AdmobProtocolAds::hideBannerAd() { hideAd(getData(this).bannerAdId_); }

void AdmobProtocolAds::moveBannerAd(AdsPos position) {
    moveAd(getData(this).bannerAdId_, position);
}

void AdmobProtocolAds::moveBannerAd(int x, int y) {
    moveAd(getData(this).bannerAdId_, x, y);
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
    getData(this).nativeExpressAdId_ = adUnitId;
    getData(this).nativeExpressAdSize_ = std::make_pair(width, height);
    createNativeExpressAd(adUnitId, width, height);
    showAd(adUnitId);
}

void AdmobProtocolAds::hideNativeExpressAd() {
    hideAd(getData(this).nativeExpressAdId_);
}

void AdmobProtocolAds::moveNativeExpressAd(AdsPos position) {
    moveAd(getData(this).nativeExpressAdId_, position);
}

void AdmobProtocolAds::moveNativeExpressAd(int x, int y) {
    moveAd(getData(this).nativeExpressAdId_, x, y);
}

void AdmobProtocolAds::showInterstitialAd() {
    callFunction(this, "showInterstitialAd");
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
    return getSizeInPixels(getData(this).bannerAdSize_.first);
}

int AdmobProtocolAds::getBannerHeightInPixels() {
    return getSizeInPixels(getData(this).bannerAdSize_.second);
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

const std::string admob::NativeAdAdvancedDetailBuilder::AssetHeadline = "asset_headline";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetBody = "asset_body";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetImage = "asset_image";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetCallToAction = "asset_call_to_action";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetIcon = "asset_icon";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetMedia = "asset_media";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetStarRating = "asset_star_rating";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetStore = "asset_store";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetPrice = "asset_price";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetAdvertiser = "asset_advertiser";
const std::string admob::NativeAdAdvancedDetailBuilder::AssetLogo = "asset_logo";

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingHealine(bool use) {
    
    params_[AssetHeadline] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingBody(bool use) {
    
    params_[AssetBody] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingImage(bool use) {
    
    params_[AssetImage] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingCallToAction(bool use) {
    
    params_[AssetCallToAction] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingIcon(bool use) {
    
    params_[AssetIcon] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingMedia(bool use) {
    
    params_[AssetMedia] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingStarRating(bool use) {
    
    params_[AssetStarRating] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingStore(bool use) {
    
    params_[AssetStore] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingPrice(bool use) {
    
    params_[AssetPrice] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingAdvertiser(bool use) {
    
    params_[AssetAdvertiser] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingLogo(bool use) {
    
    params_[AssetLogo] = BOOLSTR(use);
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingHealineId(const std::string& _id) {
    
    params_[AssetHeadline] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingBodyId(const std::string& _id) {
    
    params_[AssetBody] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingImageId(const std::string& _id) {
    
    params_[AssetImage] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingCallToActionId(const std::string& _id) {
    
    params_[AssetCallToAction] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingIconId(const std::string& _id) {
    
    params_[AssetIcon] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingMediaId(const std::string& _id) {
    
    params_[AssetMedia] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingStarRatingId(const std::string& _id) {
    
    params_[AssetStarRating] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingStoreId(const std::string& _id) {
    
    params_[AssetStore] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingPriceId(const std::string& _id) {
    
    params_[AssetPrice] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingAdvertiserId(const std::string& _id) {
    
    params_[AssetAdvertiser] = _id;
    
    return *this;
}

admob::NativeAdAdvancedDetailBuilder& admob::NativeAdAdvancedDetailBuilder::setUsingLogoId(const std::string& _id) {
    
    params_[AssetLogo] = _id;
    
    return *this;
}

const admob::NativeAdAdvancedParam& admob::NativeAdAdvancedDetailBuilder::build() const {
    return params_;
}
NS_SENSPARK_PLUGIN_ADS_END
