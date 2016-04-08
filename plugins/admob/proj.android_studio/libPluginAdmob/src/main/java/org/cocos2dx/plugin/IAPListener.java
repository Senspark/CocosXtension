package org.cocos2dx.plugin;

import com.google.android.gms.ads.purchase.InAppPurchase;
import com.google.android.gms.ads.purchase.InAppPurchaseListener;

/**
 * Created by enrevol on 4/8/16.
 */
public class IAPListener implements InAppPurchaseListener {
    private AdsAdmob adapter;

    IAPListener(AdsAdmob adapter) {
        this.adapter = adapter;
    }

    @Override
    public void onInAppPurchaseRequested(InAppPurchase inAppPurchase) {
        String productId = inAppPurchase.getProductId();
        adapter.logD(String.format("onInAppPurchaseRequested: productId = %s", productId));
        AdsWrapper.onAdsResult(adapter, AdsWrapper.RESULT_CODE_InAppPurchaseRequested, productId);
    }
}
