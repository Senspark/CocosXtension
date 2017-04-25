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
import org.w3c.dom.Text;

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
        _view = view;
        _size = view.getAdSize();
        _request = request;
    }

    AdViewInfo(@NonNull NativeCallback callback, String adId, int nativeAdvancedAdType, @NonNull NativeAdView adView, @NonNull  AdSize size, @NonNull AdRequest request, @NonNull JSONObject extras) {
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

        if ((nativeAdvancedAdType |  AdsAdmob.NativeAdAdvancedTypeAppInstall) != 0) {
            logD("Advanced Ad is consider as AppInstallAd");
            builder.forAppInstallAd(listener);
        }

        if ((nativeAdvancedAdType | AdsAdmob.NativeAdAdvancedTypeContent) != 0) {
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
        _hide();
        _pause();
    }

    private void _hide() {
        logD("_hide");
        _view.setVisibility(View.INVISIBLE);
    }

    void show() {
        logD("show");
        _show();
        _resume();
        _reload();
    }

    private void _show() {
        logD("_show");
        _view.setVisibility(View.VISIBLE);
    }

    private int getViewID(String name) {
        return _view.getResources().getIdentifier(name, "id", _view.getContext().getPackageName());
    }

    private void _displayAppInstallAd(NativeAppInstallAd ad) {
        logD("_displayAppInstallAd");
        NativeAppInstallAdView appInstallAdView = (NativeAppInstallAdView) _view;

        appInstallAdView.setNativeAd(ad);

        try {
            int headlineId = getViewID(_adExtras.getString(NativeAdAdvancedUsingHeadlineExtra));

            if (headlineId != 0) {
                TextView headlineView = (TextView) appInstallAdView.findViewById(headlineId);
                if (headlineView != null) {
                    appInstallAdView.setHeadlineView(headlineView);
                    headlineView.setText(ad.getHeadline());
                    headlineView.setVisibility(View.VISIBLE);
                }
            } else if (appInstallAdView.getHeadlineView() != null) {
                appInstallAdView.getHeadlineView().setVisibility(View.INVISIBLE);
            }

            int iconId = getViewID(_adExtras.getString(NativeAdAdvancedUsingIconExtra));
            if (iconId != 0) {
                ImageView iconView = (ImageView) appInstallAdView.findViewById(iconId);
                if (iconView != null) {
                    appInstallAdView.setIconView(iconView);
                    iconView.setImageDrawable(ad.getIcon().getDrawable());
                    iconView.setVisibility(View.VISIBLE);
                }
            } else if (appInstallAdView.getIconView() != null) {
                appInstallAdView.getIconView().setVisibility(View.INVISIBLE);
            }

            int bodyId = getViewID(_adExtras.getString(NativeAdAdvancedUsingBodyExtra));
            if (bodyId != 0) {
                TextView bodyView = (TextView) appInstallAdView.findViewById(bodyId);
                if (bodyView != null) {
                    appInstallAdView.setBodyView(bodyView);
                    bodyView.setText(ad.getBody());
                    bodyView.setVisibility(View.VISIBLE);
                }
            } else if (appInstallAdView.getBodyView() != null) {
                appInstallAdView.getBodyView().setVisibility(View.INVISIBLE);
            }

            int imageId = getViewID(_adExtras.getString(NativeAdAdvancedUsingImageExtra));
            if (imageId != 0) {
                ImageView imageView = (ImageView) appInstallAdView.findViewById(imageId);
                if (imageView != null) {
                    appInstallAdView.setImageView(imageView);
                    imageView.setImageDrawable(ad.getImages().get(0).getDrawable());
                    imageView.setVisibility(View.VISIBLE);
                }
            } else if (appInstallAdView.getImageView() !=  null) {
                appInstallAdView.getImageView().setVisibility(View.INVISIBLE);
            }

            int callToActionId = getViewID(_adExtras.getString(NativeAdAdvancedUsingCallToActionExtra));
            if (callToActionId != 0) {
                Button callToActionView = (Button) appInstallAdView.findViewById(callToActionId);
                if (callToActionView != null) {
                    appInstallAdView.setCallToActionView(callToActionView);
                    callToActionView.setText(ad.getCallToAction());
                    callToActionView.setVisibility(View.VISIBLE);
                }
            } else if (appInstallAdView.getCallToActionView() != null) {
                appInstallAdView.getCallToActionView().setVisibility(View.INVISIBLE);
            }

            int mediaId = getViewID(_adExtras.getString(NativeAdAdvancedUsingMediaExtra));
            if (mediaId != 0 && ad.getVideoController().hasVideoContent()) {
                MediaView mediaView = (MediaView) appInstallAdView.findViewById(mediaId);
                if (mediaView != null) {
                    appInstallAdView.setMediaView(mediaView);
                    mediaView.setVisibility(View.VISIBLE);
                }
            } else {
                if (appInstallAdView.getMediaView() != null) {
                    appInstallAdView.getMediaView().setVisibility(View.INVISIBLE);
                }
                if (appInstallAdView.findViewById(mediaId) != null) {
                    appInstallAdView.findViewById(mediaId).setVisibility(View.INVISIBLE);
                }
            }

            int starRatingId = getViewID(_adExtras.getString(NativeAdAdvancedUsingStarRatingExtra));
            if (starRatingId != 0 && ad.getStarRating() != 0) {
                RatingBar starRatingView = (RatingBar) appInstallAdView.findViewById(starRatingId);
                if (starRatingView != null) {
                    appInstallAdView.setStarRatingView(starRatingView);
                    starRatingView.setRating(ad.getStarRating().floatValue());
                    starRatingView.setVisibility(View.VISIBLE);
                }
            } else {
                if (appInstallAdView.getStarRatingView() != null) {
                    appInstallAdView.getStarRatingView().setVisibility(View.INVISIBLE);
                }
                if (appInstallAdView.findViewById(starRatingId) != null) {
                    appInstallAdView.findViewById(starRatingId).setVisibility(View.INVISIBLE);
                }
            }

            int storeId = getViewID(_adExtras.getString(NativeAdAdvancedUsingStoreExtra));
            if (storeId != 0 && ad.getStore() != null) {
                TextView storeView = (TextView) appInstallAdView.findViewById(storeId);
                if (storeView != null) {
                    appInstallAdView.setStoreView(storeView);
                    storeView.setText(ad.getStore());
                    storeView.setVisibility(View.VISIBLE);
                }
            } else {
                if (appInstallAdView.getStoreView() != null) {
                    appInstallAdView.getStoreView().setVisibility(View.INVISIBLE);
                }
                if (appInstallAdView.findViewById(storeId) != null) {
                    appInstallAdView.findViewById(storeId).setVisibility(View.INVISIBLE);
                }
            }

            int priceId = getViewID(_adExtras.getString(NativeAdAdvancedUsingPriceExtra));
            if (priceId != 0 && ad.getStore() != null) {
                TextView priceView = (TextView) appInstallAdView.findViewById(priceId);
                if (priceView != null) {
                    appInstallAdView.setStoreView(priceView);
                    priceView.setText(ad.getPrice());
                    priceView.setVisibility(View.VISIBLE);
                }
            } else {
                if (appInstallAdView.getPriceView() != null) {
                    appInstallAdView.getPriceView().setVisibility(View.INVISIBLE);
                }
                if (appInstallAdView.findViewById(priceId) != null) {
                    appInstallAdView.findViewById(priceId).setVisibility(View.INVISIBLE);
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void _displayContentAd(NativeContentAd ad) {
        logD("_displayContentAd");
        NativeContentAdView contentAdView = (NativeContentAdView) _view;

        contentAdView.setNativeAd(ad);

        try {
            int headlineId = getViewID(_adExtras.getString(NativeAdAdvancedUsingHeadlineExtra));
            if (headlineId != 0) {
                TextView headlineView = (TextView) contentAdView.findViewById(headlineId);
                if (headlineView != null) {
                    contentAdView.setHeadlineView(headlineView);
                    headlineView.setText(ad.getHeadline());
                    headlineView.setVisibility(View.VISIBLE);
                }
            } else if (contentAdView.getHeadlineView() != null) {
                contentAdView.getHeadlineView().setVisibility(View.INVISIBLE);
            }

            int bodyId = getViewID(_adExtras.getString(NativeAdAdvancedUsingBodyExtra));
            if (bodyId != 0) {
                TextView bodyView = (TextView) contentAdView.findViewById(bodyId);
                if (bodyView != null) {
                    contentAdView.setBodyView(bodyView);
                    bodyView.setText(ad.getBody());
                    bodyView.setVisibility(View.VISIBLE);
                }
            } else if (contentAdView.getBodyView() != null) {
                contentAdView.getBodyView().setVisibility(View.INVISIBLE);
            }

            int advertiserId = getViewID(_adExtras.getString(NativeAdAdvancedUsingAdvertiserExtra));
            if (advertiserId != 0) {
                TextView advertiserView = (TextView) contentAdView.findViewById(advertiserId);
                if (advertiserView != null) {
                    contentAdView.setAdvertiserView(advertiserView);
                    advertiserView.setText(ad.getAdvertiser());
                    advertiserView.setVisibility(View.VISIBLE);
                }
            } else if (contentAdView.getAdvertiserView() != null) {
                contentAdView.getAdvertiserView().setVisibility(View.INVISIBLE);
            }

            int imageId = getViewID(_adExtras.getString(NativeAdAdvancedUsingImageExtra));
            if (imageId != 0) {
                ImageView imageView = (ImageView) contentAdView.findViewById(imageId);
                if (imageView != null) {
                    contentAdView.setImageView(imageView);
                    imageView.setImageDrawable(ad.getImages().get(0).getDrawable());
                    imageView.setVisibility(View.VISIBLE);
                }
            } else if (contentAdView.getImageView() != null) {
                contentAdView.getImageView().setVisibility(View.INVISIBLE);
            }

            int callToActionId = getViewID(_adExtras.getString(NativeAdAdvancedUsingCallToActionExtra));
            if (callToActionId != 0) {
                Button callToActionView = (Button) contentAdView.findViewById(callToActionId);
                if (callToActionView != null) {
                    contentAdView.setCallToActionView(callToActionView);
                    callToActionView.setText(ad.getCallToAction());
                    callToActionView.setVisibility(View.VISIBLE);
                }
            } else if (contentAdView.getCallToActionView() != null) {
                contentAdView.getCallToActionView().setVisibility(View.INVISIBLE);
            }

            int logoId = getViewID(_adExtras.getString(NativeAdAdvancedUsingLogoExtra));
            if (logoId != 0) {
                ImageView logoView = (ImageView) contentAdView.findViewById(logoId);
                if (logoView != null) {
                    contentAdView.setLogoView(logoView);
                    logoView.setImageDrawable(ad.getLogo().getDrawable());
                    logoView.setVisibility(View.VISIBLE);
                }
            } else if (contentAdView.getLogoView() != null) {
                contentAdView.getLogoView().setVisibility(View.INVISIBLE);
            }
        } catch (JSONException e) {
            e.printStackTrace();
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
            logD("_reload");
            if (_adLoader != null) {
                _adLoader.loadAd(_request);
            } else if (_view instanceof AdView) {
                AdView view = (AdView) _view;
                view.loadAd(_request);
            } else if (_view instanceof NativeExpressAdView) {
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