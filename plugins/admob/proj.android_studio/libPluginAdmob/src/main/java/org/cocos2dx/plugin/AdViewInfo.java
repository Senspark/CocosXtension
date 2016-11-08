package org.cocos2dx.plugin;

import android.graphics.Color;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.NativeExpressAdView;

/**
 * Created by Zinge on 10/19/16.
 */
class AdViewInfo {
    private static final String _Tag = AdViewInfo.class.getName();

    private View      _view;
    private AdSize    _size;
    private AdRequest _request;

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
        _view.setBackgroundColor(Color.BLACK);
        /*
        // Can also use.
        _view.setVisibility(View.GONE); // View.INVISIBLE won't work.
        _view.setVisibility(View.VISIBLE);
        */
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
            if (_view instanceof AdView) {
                AdView view = (AdView) _view;
                view.loadAd(_request);
            } else if (_view instanceof NativeExpressAdView) {
                NativeExpressAdView view = (NativeExpressAdView) _view;
                view.loadAd(_request);
            }
        }
    }

    private boolean _isLoading() {
        if (_view instanceof AdView) {
            return ((AdView) _view).isLoading();
        }
        if (_view instanceof NativeExpressAdView) {
            return ((NativeExpressAdView) _view).isLoading();
        }
        return false;
    }
}