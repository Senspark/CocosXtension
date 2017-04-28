package org.cocos2dx.plugin;

import android.graphics.Color;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import com.google.android.gms.ads.AdLoader;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.NativeExpressAdView;
import com.google.android.gms.ads.formats.MediaView;
import com.google.android.gms.ads.formats.NativeAdView;
import com.google.android.gms.ads.formats.NativeAppInstallAd;
import com.google.android.gms.ads.formats.NativeAppInstallAdView;
import com.google.android.gms.ads.formats.NativeContentAd;
import com.google.android.gms.ads.formats.NativeContentAdView;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by Zinge on 10/19/16.
 */
class AdViewInfo {
    private static final String _Tag = AdViewInfo.class.getName();

    private View      _view;
    private AdSize    _size;
    private AdRequest _request;
    private AdLoader  _adLoader;
    private JSONObject _adExtras;
    private boolean _isHiden;

    /// common assets
    private static final String NativeAdAdvancedUsingHeadlineExtra   = "asset_headline";
    private static final String NativeAdAdvancedUsingBodyExtra       = "asset_body";
    private static final String NativeAdAdvancedUsingImageExtra      = "asset_image";
    private static final String NativeAdAdvancedUsingCallToActionExtra    = "asset_call_to_action";
///

/// app install ad assets
    private static final String NativeAdAdvancedUsingIconExtra       = "asset_icon";
    private static final String NativeAdAdvancedUsingMediaExtra      = "asset_media";
    private static final String NativeAdAdvancedUsingStarRatingExtra = "asset_star_rating";
    private static final String NativeAdAdvancedUsingStoreExtra      = "asset_store";
    private static final String NativeAdAdvancedUsingPriceExtra      = "asset_price";
///

/// content view ad assets
    private static final String NativeAdAdvancedUsingAdvertiserExtra = "asset_advertiser";
    private static final String NativeAdAdvancedUsingLogoExtra       = "asset_logo";

    AdViewInfo(@NonNull NativeCallback callback, @NonNull final AdView view,
               @NonNull AdRequest request) {
        view.setAdListener(new BannerAdListener(callback) {
            @Override
            public void onAdLoaded() {
                super.onAdLoaded();
                _invalidate();
            }
        });
        _isHiden = false;
        _view = view;
        _size = view.getAdSize();
        _request = request;
    }

    AdViewInfo(@NonNull NativeCallback callback, @NonNull NativeExpressAdView view,
               @NonNull AdRequest request) {
        view.setAdListener(new NativeExpressAdListener(callback) {
            @Override
            public void onAdLoaded() {
                super.onAdLoaded();
                _invalidate();
            }
        });
        _isHiden = false;
        _view = view;
        _size = view.getAdSize();
        _request = request;
    }

    AdViewInfo(@NonNull NativeCallback callback, String adId, int nativeAdvancedAdType, @NonNull NativeAdView adView, @NonNull  AdSize size, @NonNull AdRequest request, @NonNull JSONObject extras) {
        _isHiden = false;
        _view = adView;
        _size = size;
        _request = request;
        _adExtras = extras;

        NativeAdvancedAdListener listener = new NativeAdvancedAdListener(callback, adView) {
            @Override
            public void onAppInstallAdLoaded(NativeAppInstallAd ad) {
                super.onAppInstallAdLoaded(ad);
                _displayAppInstallAd(ad);
            }

            @Override
            public void onContentAdLoaded(NativeContentAd ad) {
                super.onContentAdLoaded(ad);
                _displayContentAd(ad);
            }
        };

        AdLoader.Builder builder = new AdLoader.Builder(_view.getContext(), adId);
        logD("Ad Advanced Type is: " + nativeAdvancedAdType);

        if ((nativeAdvancedAdType &  AdsAdmob.NativeAdAdvancedTypeAppInstall) != 0) {
            logD("Advanced Ad is consider as AppInstallAd");
            builder.forAppInstallAd(listener);
        }

        if ((nativeAdvancedAdType & AdsAdmob.NativeAdAdvancedTypeContent) != 0) {
            logD("Advanced Ad is consider as ContentAd");
            builder.forContentAd(listener);
        }

        builder.withAdListener(listener);

        _adLoader = builder.build();
    }

    private void logD(String message) {
        Log.d(_Tag, message);
    }

    View getView() {
        return _view;
    }

    AdSize getAdSize() {
        return _size;
    }

    private boolean _isVisible() {
        return _view.getVisibility() == View.VISIBLE;
    }

    private void _invalidate() {
        logD("_invalidate");
        if (_isVisible()) {
            __invalidate();
        }
    }

    private void __invalidate() {
        logD("__invalidate");

        if (_adLoader == null) {
            _view.setBackgroundColor(Color.BLACK);

        } else {
            //for nativeadvancedad
            _view.setVisibility(View.GONE); // View.INVISIBLE won't work.
            _view.setVisibility(View.VISIBLE);
        }
    }

    void hide() {
        logD("hide");
        _isHiden = true;
        _hide();
        _pause();
    }

    private void _hide() {
        logD("_hide");
        _view.setVisibility(View.INVISIBLE);
    }

    void show() {
        logD("show");
        _isHiden = false;
        _show();
        _resume();
        _reload();
    }

    private void _show() {
        logD("_show");
        if (_adLoader == null) {
            _view.setVisibility(View.VISIBLE);
        }
    }

    private int getAssetViewID(String field) {
        if (_adExtras == null) {
            return 0;
        }
        try {
            if (_adExtras.has(field)) {
                String fieldId = _adExtras.getString(field);
                return _view.getResources().getIdentifier(fieldId, "id", _view.getContext().getPackageName());
            } else {
                logD("Not defined " + field);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private View getAssetView(View adView, String assetField) {
        int assetId = getAssetViewID(assetField);
        if (assetId != 0) {
            View assetView = adView.findViewById(assetId);
            if (assetView != null) {
                assetView.setVisibility(View.VISIBLE);
                return assetView;
            }
        }
        return null;
    }

    private void _displayAppInstallAd(NativeAppInstallAd ad) {
        logD("_displayAppInstallAd");
        if(!_isHiden) {
            _view.setVisibility(View.VISIBLE);
        }
        
        NativeAppInstallAdView appInstallAdView = (NativeAppInstallAdView) _view;

        appInstallAdView.setNativeAd(ad);

        TextView headlineView = (TextView) getAssetView(appInstallAdView, NativeAdAdvancedUsingHeadlineExtra);
        if (headlineView != null) {
            appInstallAdView.setHeadlineView(headlineView);
            headlineView.setText(ad.getHeadline());
        }

        ImageView iconView = (ImageView) getAssetView(appInstallAdView, NativeAdAdvancedUsingIconExtra);
        if (iconView != null) {
            appInstallAdView.setIconView(iconView);
            iconView.setImageDrawable(ad.getIcon().getDrawable());
        }

        TextView bodyView = (TextView) getAssetView(appInstallAdView, NativeAdAdvancedUsingBodyExtra);
        if (bodyView != null) {
            appInstallAdView.setBodyView(bodyView);
            bodyView.setText(ad.getBody());
        }

        ImageView imageView = (ImageView) getAssetView(appInstallAdView, NativeAdAdvancedUsingImageExtra);
        if (imageView != null) {
            appInstallAdView.setImageView(imageView);
            imageView.setImageDrawable(ad.getImages().get(0).getDrawable());
        }

        Button callToActionView = (Button) getAssetView(appInstallAdView, NativeAdAdvancedUsingCallToActionExtra);
        if (callToActionView != null) {
            appInstallAdView.setCallToActionView(callToActionView);
            callToActionView.setText(ad.getCallToAction());
        }

        MediaView mediaView = (MediaView) getAssetView(appInstallAdView, NativeAdAdvancedUsingMediaExtra);
        if (mediaView != null) {
            appInstallAdView.setMediaView(mediaView);
        }

        RatingBar starRatingView = (RatingBar) getAssetView(appInstallAdView, NativeAdAdvancedUsingStarRatingExtra);
        if (starRatingView != null) {
            appInstallAdView.setStarRatingView(starRatingView);
            starRatingView.setRating(ad.getStarRating().floatValue());
            logD("Native Advanced Ad - Rating: " + ad.getStarRating().floatValue());
        }

        TextView storeView = (TextView) getAssetView(appInstallAdView, NativeAdAdvancedUsingStoreExtra);
        if (storeView != null) {
            appInstallAdView.setStoreView(storeView);
            storeView.setText(ad.getStore());
        }

        TextView priceView = (TextView) getAssetView(appInstallAdView, NativeAdAdvancedUsingPriceExtra);
        if (priceView != null) {
            appInstallAdView.setPriceView(priceView);
            priceView.setText(ad.getPrice());
        }
    }

    private void _displayContentAd(NativeContentAd ad) {
        logD("_displayContentAd");
        if(!_isHiden) {
            _view.setVisibility(View.VISIBLE);
        }
        NativeContentAdView contentAdView = (NativeContentAdView) _view;

        contentAdView.setNativeAd(ad);

        TextView headlineView = (TextView) getAssetView(contentAdView, NativeAdAdvancedUsingHeadlineExtra);
        if (headlineView != null) {
            contentAdView.setHeadlineView(headlineView);
            headlineView.setText(ad.getHeadline());
        }

        TextView bodyView = (TextView) getAssetView(contentAdView, NativeAdAdvancedUsingBodyExtra);
        if (bodyView != null) {
            contentAdView.setBodyView(bodyView);
            bodyView.setText(ad.getBody());
        }

        TextView advertiserView = (TextView) getAssetView(contentAdView, NativeAdAdvancedUsingAdvertiserExtra);
        if (advertiserView != null) {
            contentAdView.setAdvertiserView(advertiserView);
            advertiserView.setText(ad.getAdvertiser());
        }

        ImageView imageView = (ImageView) getAssetView(contentAdView, NativeAdAdvancedUsingImageExtra);
        if (imageView != null) {
            contentAdView.setImageView(imageView);
            imageView.setImageDrawable(ad.getImages().get(0).getDrawable());
        }

        Button callToActionView = (Button) getAssetView(contentAdView, NativeAdAdvancedUsingCallToActionExtra);
        if (callToActionView != null) {
            contentAdView.setCallToActionView(callToActionView);
            callToActionView.setText(ad.getCallToAction());
        }

        ImageView logoView = (ImageView) getAssetView(contentAdView, NativeAdAdvancedUsingLogoExtra);
        if (logoView != null) {
            contentAdView.setLogoView(logoView);
            logoView.setImageDrawable(ad.getLogo().getDrawable());
        }
    }

    void pause() {
        logD("pause");
        if (_isVisible()) {
            _pause();
        }
    }

    void resume() {
        logD("resume");
        if (_isVisible()) {
            _resume();
        }
    }

    void destroy() {
        logD("destroy");
        if (_view instanceof AdView) {
            ((AdView) _view).destroy();
        } else if (_view instanceof NativeExpressAdView) {
            ((NativeExpressAdView) _view).destroy();
        }
        if (_adLoader != null) {
            ((NativeAdView) _view).destroy();
        }
        ((ViewGroup) _view.getParent()).removeView(_view);
    }

    void move(@NonNull Integer x, @NonNull Integer y) {
        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) _view.getLayoutParams();
        params.leftMargin = x;
        params.topMargin = y;
        _view.setLayoutParams(params);
    }

    private void _pause() {
        logD("_pause");
        if (_view instanceof AdView) {
            ((AdView) _view).pause();
        } else if (_view instanceof NativeExpressAdView) {
            ((NativeExpressAdView) _view).pause();
        }
    }

    private void _resume() {
        logD("_resume");
        if (_view instanceof AdView) {
            ((AdView) _view).resume();
        } else if (_view instanceof NativeExpressAdView) {
            ((NativeExpressAdView) _view).resume();
        }
    }

    private void _reload() {
        if (!_isLoading()) {
            if (_adLoader != null) {
                logD("_reload NativeAdAdvanced");
                _adLoader.loadAd(_request);
            } else if (_view instanceof AdView) {
                logD("_reload Banner");
                AdView view = (AdView) _view;
                view.loadAd(_request);
            } else if (_view instanceof NativeExpressAdView) {
                logD("_reload NativeExpressedAd");
                NativeExpressAdView view = (NativeExpressAdView) _view;
                view.loadAd(_request);
            }
        }
    }

    private boolean _isLoading() {
        if (_adLoader != null) {
            return _adLoader.isLoading();
        }
        if (_view instanceof AdView) {
            return ((AdView) _view).isLoading();
        }
        if (_view instanceof NativeExpressAdView) {
            return ((NativeExpressAdView) _view).isLoading();
        }
        return false;
    }
}