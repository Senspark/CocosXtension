//
//  SensparkProtocolAds.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/16/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_SensparkProtocolAds_h
#define PluginSenspark_SensparkProtocolAds_h

#include "ProtocolAds.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_ADS_BEGIN

#define GAD_SIMULATOR_ID "Simulator"

/*

 AdMobProtocolAds synopsis:

 - add_test_devices

 - show_banner_ad(ad_id, ad_size, position)
 - hide_banner_ad

 - show_native_express_ad(ad_id, ad_size, position)
 - hide_native_express_ad

 - show_interstitial_ad
 - load_interstitial_ad(ad_id)
 - has_interstitial_ad : bool

 - show_rewarded_video_ad
 - load_rewarded_video_ad(ad_id)
 - has_rewarded_video_ad : bool

 - get_size_in_pixels(dp) : int

 */

/// Some examples.
/// @code
/// TAdsInfo info;
/// info[AdmobProtocolAds::AdTypeKey] = AdmobProtocolAds::AdType::Banner;
/// info[AdmobProtocolAds::AdSizeKey] = AdmobProtocolAds::AdSize::LargeBanner;
/// your_admob_protocol_ads_instance->showAds(info);
/// @endcode
///
/// @code
/// TAdsInfo info;
/// info[AdmobProtocolAds::AdIdKey] = "your_ad_id";
/// your_admob_protocol_ads_instance->configDeveloperInfo(info);
/// @endcode
class AdmobProtocolAds : public cocos2d::plugin::ProtocolAds {
public:
    class AdType;
    class AdSize;

    /// Ad id key used in TAdsInfo.
    CC_DEPRECATED_ATTRIBUTE static const std::string AdBannerIdKey;
    CC_DEPRECATED_ATTRIBUTE static const std::string AdInterstitialIdKey;

    /// Ad type key used in TAdsInfo.
    CC_DEPRECATED_ATTRIBUTE static const std::string AdTypeKey;

    /// Ad size key used in TAdsInfo.
    CC_DEPRECATED_ATTRIBUTE static const std::string AdSizeKey;

    AdmobProtocolAds();
    virtual ~AdmobProtocolAds();

    CC_DEPRECATED_ATTRIBUTE void configureAds(const std::string& adsId);

    CC_DEPRECATED_ATTRIBUTE void
    configureAds(const std::string& bannerAds,
                 const std::string& interstitialAds);

    void addTestDevice(const std::string& deviceId);

    /// Configure AdMob mediation with AdColony.
    /// Available keys:
    /// - "AdColonyAppID": The AdColony application id (must have).
    /// - "AdColonyInterstitialAdID": Interstitial zone id used to display AdMob
    /// interstitial ads (optional).
    /// - "AdColonyRewardedAdID": Rewarded V4VC zone id used to display AdMob
    /// rewarded videos (optional).
    void configMediationAdColony(const cocos2d::plugin::TAdsInfo& params);

    /// Shows a banner ad given its id, size and position (optional).
    void showBannerAd(const std::string& bannerAdId, AdSize bannerAdSize,
                      AdsPos bannerAdPosition = AdsPos::kPosCenter);

    /// Hides current banner ad (if shown).
    void hideBannerAd();

    /// Moves the displaying banner ad to the specified location.
    /// @param x Vertical distance from the top border of the device screen in
    /// pixels.
    /// @param y Horizontal distance from the left border of the device screen
    /// in pixels.
    void moveBannerAd(int x, int y);

    /// https://firebase.google.com/docs/admob/android/native-express
    /// https://firebase.google.com/docs/admob/ios/native-express
    /// @param adUnitId The id of the ad.
    /// @param width The desired width of the ad view in DP (density-independent
    /// pixel), pass -1 for full width.
    /// @param height The desired width of the ad view in DP
    /// (density-independent pixel), pass -2 for auto
    /// height.
    void showNativeExpressAd(const std::string& adUnitId, int width, int height,
                             AdsPos position);

    /// @see showNativeExpressAd
    /// @param x Horizontal distance from the left border of the device screen
    /// in pixels.
    /// @param y Vertical distance from the top border of the device screen in
    /// pixels.
    void showNativeExpressAd(const std::string& adUnitId, int width, int height,
                             int x, int y);

    /// Moves the displaying native express ad to the specified location.
    /// @param x Vertical distance from the top border of the device screen in
    /// pixels.
    /// @param y Horizontal distance from the left border of the device screen
    /// in pixels.
    void moveNativeExpressAd(int x, int y);

    /// Hides the currently displaying native express ad (if any).
    void hideNativeExpressAd();

    /// Shows an interstitial ad.
    void showInterstitialAd();

    CC_DEPRECATED_ATTRIBUTE void
    showInterstitialAd(const std::string& interstitialAdId);

    /// Shows an interstitial ad given its id and a callback when user requested
    /// an in-app purchase.
    ///
    /// Only works on Android.
    ///
    /// Example.
    /// @code
    /// your_admob_protocol_ads_instance->showInterstitialAds(
    ///     your_interstitial_ad_id,
    ///     [](AdsResultCode code, const std::string& msg) {
    ///         if (code == AdsResultCode::kIapPurchaseRequested) {
    ///             auto productId = msg;
    ///             /// Process your iap mechanism with productId here.
    ///         }
    /// });
    /// @endcode
    CC_DEPRECATED_ATTRIBUTE void
    showInterstitialAd(const std::string& interstitialAdId,
                       const AdsCallback& iapCallback);

    CC_DEPRECATED_ATTRIBUTE void loadInterstitial();

    void loadInterstitialAd(const std::string& adId);

    bool hasInterstitialAd();

    /// Checks whether there is any available interstitial ad.
    CC_DEPRECATED_ATTRIBUTE bool hasInterstitial() {
        return hasInterstitialAd();
    }

    /// Attempts to show the loaded rewarded video ad.
    /// No-op if there is not any rewarded video ad.
    void showRewardedAd();

    /// Attempts to load a rewarded video ad with the specified id.
    /// Ignored if the last loading try is in progress.
    void loadRewardedAd(const std::string& adId);

    /// Checks whether there is any available rewarded video ad to show.
    bool hasRewardedAd();

    /// Gets the current displaying banner ad's width in pixels.
    /// For getting the specified banner ad size, refer @c getSizeInPixels.
    /// @note If there is no displaying banner, returns 0.
    int getBannerWidthInPixels();

    /// Gets the current displaying banner ad's height in pixels.
    /// For getting the specified banner ad size, refer @c getSizeInPixels.
    /// @note If there is no displaying banner, returns 0.
    int getBannerHeightInPixels();

    /// Gets the size of the banner ad in pixels.
    /// @param size In DP (density-independent pixel), pass -1 for full width,
    /// -2 for auto height.
    int getSizeInPixels(int size);

    CC_DEPRECATED_ATTRIBUTE int getBannerWidthInPixel() {
        return getBannerWidthInPixels();
    }

    CC_DEPRECATED_ATTRIBUTE int getBannerHeightInPixel() {
        return getBannerHeightInPixels();
    }
};

class CC_DEPRECATED_ATTRIBUTE AdmobProtocolAds::AdType {
public:
    static const AdType Banner;

    /// Fullscreen ad.
    static const AdType Interstitial;

    /// Implicit conversion to std::string to be stored in TAdsInfo.
    operator const std::string&() const;

    const std::string& getDescription() const;

private:
    explicit AdType(const std::string& s);

    std::string _s;
};

class AdmobProtocolAds::AdSize {
public:
    /// iPhone and iPod Touch ad size.
    ///
    /// Equivalent to @c kGADAdSizeBanner on iOS or
    /// @c AdSize.BANNER on Android.
    ///
    /// Typically 320x50.
    static const AdSize Banner;

    /// Taller version of Banner.
    ///
    /// Equivalent to @c kGADAdSizeLargeBanner on iOS or
    /// @c AdSize.LARGE_BANNER on Android.
    ///
    /// Typically 320x100.
    static const AdSize LargeBanner;

    /// Medium Rectangle size for the iPad.
    ///
    /// Equivalent to @c kGADAdSizeMediumRectangle on iOS or
    /// @c AdSize.MEDIUM_RECTANGLE on Android.
    ///
    /// Typically 300x250.
    static const AdSize MediumRectangle;

    /// Full Banner size for the iPad.
    ///
    /// Equivalent to @c kGADAdSizeFullBanner on iOS or
    /// @c AdSize.FULL_BANNER on Android.
    ///
    /// Typically 468x60.
    static const AdSize FullBanner;

    /// Leaderboard size for the iPad.
    ///
    /// Equivalent to @c kGADAdSizeLeaderboard on iOS or
    /// @c AdSize.LEADERBOARD on Android.
    ///
    /// Typically 728x90.
    static const AdSize Leaderboard;

    /// Skyscraper size for the iPad. Mediation only.
    ///
    /// Equivalent to @c kGADAdSizeSkyscraper on iOS or
    /// @c AdSize.WIDE_SKYSCRAPER on Android.
    ///
    /// Typically 120x600 on @c iOS or 160x600 on @c Android.
    static const AdSize Skyscraper;

    /// An ad size that spans the full width of the application in landscape
    /// orientation.
    ///
    /// The height is typically 32 pixels on an iPhone/iPod UI, and 90 pixels
    /// tall on an iPad UI.
    ///
    /// Equivalent to @c kGADAdSizeSmartBannerLandscape on iOS or
    /// @c AdSize.SMART_BANNER on Android.
    static const AdSize SmartBanner;

    /// Implicit conversion to std::string to be stored in TAdsInfo.
    operator const std::string&() const;

    const std::string& getDescription() const;

private:
    explicit AdSize(const std::string& s);

    std::string _s;
};

NS_SENSPARK_PLUGIN_ADS_END

#endif
