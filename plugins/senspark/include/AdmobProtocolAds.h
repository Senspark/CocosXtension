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
    static const std::string AdIdKey;
    
    /// Ad type key used in TAdsInfo.
    static const std::string AdTypeKey;
    
    /// Ad size key used in TAdsInfo.
    static const std::string AdSizeKey;
    
    AdmobProtocolAds();
    virtual ~AdmobProtocolAds();
    
    void configureAds(const std::string& adsId);
    
    void addTestDevice(const std::string& deviceId);
    
    /// Shows a banner ad given its id, size and position (optional).
    void showBannerAd(const std::string& bannerAdId, AdSize bannerAdSize,
                      AdsPos bannerAdPosition = AdsPos::kPosCenter);
    
    /// Hides current banner ad (if shown).
    void hideBannerAd();
    
    /// Shows an interstitial ad given its id.
    void showInterstitialAd(const std::string& interstitialAdId);
    
    /// Shows an interstitial ad given its id and a callback when user requested
    /// an in-app purchase.
    ///
    /// Only works on Android.
    void showInterstitialAd(const std::string& interstitialAdId,
                            const AdsCallback& iapCallback);

    void loadInterstitial();
    bool hasInterstitial();

    void loadRewardedAd();
    void showRewardedAd();
    bool hasRewardedAd();

    void slideBannerUp();
    void slideBannerDown();

    int getBannerWidthInPixel();
    int getBannerHeightInPixel();

    void configMediationAdColony(const cocos2d::plugin::TAdsInfo &params);
    void configMediationAdVungle(const cocos2d::plugin::TAdsInfo &params);
    void configMediationAdUnity(const cocos2d::plugin::TAdsInfo &params);
    
};

class AdmobProtocolAds::AdType {
public:
    static const AdType Banner;
    
    /// Fullscreen ad.
    static const AdType Interstitial;
    
    /// Implicit conversion to std::string to be stored in TAdsInfo.
    operator std::string() const;
    
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
    
    /// An ad size that spans the full width of the application in landscape orientation.
    ///
    /// The height is typically 32 pixels on an iPhone/iPod UI, and 90 pixels tall on an iPad UI.
    ///
    /// Equivalent to @c kGADAdSizeSmartBannerLandscape on iOS or
    /// @c AdSize.SMART_BANNER on Android.
    static const AdSize SmartBanner;
    
    /// Implicit conversion to std::string to be stored in TAdsInfo.
    operator std::string() const;
    
private:
    explicit AdSize(const std::string& s);
    
    std::string _s;
};

NS_SENSPARK_PLUGIN_ADS_END

#endif
