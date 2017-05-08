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

namespace admob {
/// The constants are correspondent with:
///     - kGADAdLoaderAdTypeNativeAppInstall
///     - kGADAdLoaderAdTypeNativeContent
    enum class NativeAdAdvancedType {
        AppInstall  = 0x01,
        Content     = 0x02,
    };
    
    class NativeAdAdvancedDetailBuilder;
    
    using NativeAdAdvancedParam = std::map<std::string, std::string>;
};


class AdmobProtocolAds : public cocos2d::plugin::ProtocolAds {
public:
    class AdSize;
    
    AdmobProtocolAds();
    virtual ~AdmobProtocolAds();

    void initialize(const std::string& applicationId);

    void addTestDevice(const std::string& deviceId);

    /// Configure AdMob mediation with AdColony.
    /// Available keys:
    /// - "AdColonyAppID": The AdColony application id (must have).
    /// - "AdColonyInterstitialAdID": Interstitial zone id used to display AdMob
    /// interstitial ads (optional).
    /// - "AdColonyRewardedAdID": Rewarded V4VC zone id used to display AdMob
    /// rewarded videos (optional).
    void configMediationAdColony(const cocos2d::plugin::TAdsInfo& params);

    /// Creates a banner ad.
    /// @param adId the id of the banner ad.
    /// @param width The width of the banner ad in dp, pass -1 for full width.
    /// @param height The height of the banner ad in dp, pass -2 for
    /// auto-height.
    void createBannerAd(const std::string& adId, int width, int height);

    /// Creates a native express ad.
    /// @see createBannerAd.
    void createNativeExpressAd(const std::string& adId, int width, int height);
    
    //
    void createNativeAdvancedAd(const std::string& adId, admob::NativeAdAdvancedType type, const std::string& layoutId, int width, int height, const admob::NativeAdAdvancedParam& params);

    /// Destroys the specified banner/native express ad.
    /// @param adId.
    void destroyAd(const std::string& adId);

    /// Shows the specified banner/native express ad.
    void showAd(const std::string& adId);

    /// Hides the specified banner/native express ad.
    void hideAd(const std::string& adId);

    /// Moves the specified banner/native express ad to the specified location.
    /// @param adId The ad id.
    /// @param x The horizontal coordinate of the desired position in pixels.
    /// @param y The vertical coordinate of the desired position in pixels.
    void moveAd(const std::string& adId, int x, int y);

    void moveAd(const std::string& adId, AdsPos position);

    std::pair<int, int> getAdSize(const std::string& adId);

    std::pair<int, int> getAdSizeInPixels(const std::string& adId);

    /// Shows a banner ad given its id, size and position (optional).
    CC_DEPRECATED_ATTRIBUTE
    void showBannerAd(const std::string& bannerAdId, AdSize bannerAdSize,
                      AdsPos bannerAdPosition = AdsPos::kPosCenter);

    CC_DEPRECATED_ATTRIBUTE
    void showBannerAd(const std::string& bannerAdId, int width, int height);

    /// Hides current banner ad (if shown).
    CC_DEPRECATED_ATTRIBUTE
    void hideBannerAd();

    CC_DEPRECATED_ATTRIBUTE
    void moveBannerAd(AdsPos position);

    /// Moves the displaying banner ad to the specified location.
    /// @param x Vertical distance from the top border of the device screen in
    /// pixels.
    /// @param y Horizontal distance from the left border of the device screen
    /// in pixels.
    CC_DEPRECATED_ATTRIBUTE
    void moveBannerAd(int x, int y);

    /// https://firebase.google.com/docs/admob/android/native-express
    /// https://firebase.google.com/docs/admob/ios/native-express
    /// @param adUnitId The id of the ad.
    /// @param width The desired width of the ad view in DP (density-independent
    /// pixel), pass -1 for full width.
    /// @param height The desired width of the ad view in DP
    /// (density-independent pixel), pass -2 for auto
    /// height.
    CC_DEPRECATED_ATTRIBUTE
    void showNativeExpressAd(const std::string& adUnitId, int width, int height,
                             AdsPos position);

    /// @see showNativeExpressAd
    /// @param x Horizontal distance from the left border of the device screen
    /// in pixels.
    /// @param y Vertical distance from the top border of the device screen in
    /// pixels.
    CC_DEPRECATED_ATTRIBUTE
    void showNativeExpressAd(const std::string& adUnitId, int width, int height,
                             int x, int y);

    CC_DEPRECATED_ATTRIBUTE
    void showNativeExpressAd(const std::string& adUnitId, int width,
                             int height);

    /// Hides the currently displaying native express ad (if any).
    CC_DEPRECATED_ATTRIBUTE
    void hideNativeExpressAd();

    CC_DEPRECATED_ATTRIBUTE
    void moveNativeExpressAd(AdsPos position);

    /// Moves the displaying native express ad to the specified location.
    /// @param x Vertical distance from the top border of the device screen in
    /// pixels.
    /// @param y Horizontal distance from the left border of the device screen
    /// in pixels.
    CC_DEPRECATED_ATTRIBUTE
    void moveNativeExpressAd(int x, int y);

    /// Shows an interstitial ad.
    void showInterstitialAd();

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
    CC_DEPRECATED_ATTRIBUTE
    int getBannerWidthInPixels();

    /// Gets the current displaying banner ad's height in pixels.
    /// For getting the specified banner ad size, refer @c getSizeInPixels.
    /// @note If there is no displaying banner, returns 0.
    CC_DEPRECATED_ATTRIBUTE
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

private:
    std::pair<int, int> computeAdViewPosition(AdsPos position, int width,
                                              int height);
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
    friend AdmobProtocolAds;

    explicit AdSize(const std::string& s, int w, int h);

    std::string _s;
    int _w;
    int _h;
};

class admob::NativeAdAdvancedDetailBuilder {
public:
    NativeAdAdvancedDetailBuilder& setUsingHealine(bool use);
    NativeAdAdvancedDetailBuilder& setUsingBody(bool use);
    NativeAdAdvancedDetailBuilder& setUsingImage(bool use);
    NativeAdAdvancedDetailBuilder& setUsingCallToAction(bool use);
    NativeAdAdvancedDetailBuilder& setUsingIcon(bool use);
    NativeAdAdvancedDetailBuilder& setUsingMedia(bool use);
    NativeAdAdvancedDetailBuilder& setUsingStarRating(bool use);
    NativeAdAdvancedDetailBuilder& setUsingStore(bool use);
    NativeAdAdvancedDetailBuilder& setUsingPrice(bool use);
    NativeAdAdvancedDetailBuilder& setUsingAdvertiser(bool use);
    NativeAdAdvancedDetailBuilder& setUsingLogo(bool use);

    NativeAdAdvancedDetailBuilder& setUsingHealineId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingBodyId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingImageId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingCallToActionId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingIconId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingMediaId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingStarRatingId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingStoreId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingPriceId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingAdvertiserId(const std::string& _id);
    NativeAdAdvancedDetailBuilder& setUsingLogoId(const std::string& _id);

    const NativeAdAdvancedParam& build() const;

protected:
    static const std::string AssetHeadline;
    static const std::string AssetBody;
    static const std::string AssetImage;
    static const std::string AssetCallToAction;
    static const std::string AssetIcon;
    static const std::string AssetMedia;
    static const std::string AssetStarRating;
    static const std::string AssetStore;
    static const std::string AssetPrice;
    static const std::string AssetAdvertiser;
    static const std::string AssetLogo;
    
private:
    NativeAdAdvancedParam params_;
};

NS_SENSPARK_PLUGIN_ADS_END

#endif
