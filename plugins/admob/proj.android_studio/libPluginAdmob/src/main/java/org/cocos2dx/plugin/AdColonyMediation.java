package org.cocos2dx.plugin;

import android.app.Activity;
import android.os.Bundle;

import com.google.android.gms.ads.AdRequest;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * Created by Zinge on 10/19/16.
 */

class AdColonyMediation {
    static boolean isLinkedWithAdColony() {
        try {
            Class.forName("com.jirbo.adcolony.AdColony");
            Class.forName("com.jirbo.adcolony.AdColonyAdapter");
            Class.forName("com.jirbo.adcolony.AdColonyBundleBuilder");
            return true;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    static void configure(Activity activity, String clientOptions, String appId,
                          String... zoneIds) {
        if (isLinkedWithAdColony()) {
            try {
                Class clazz = Class.forName("com.jirbo.adcolony.AdColony");
                Method method =
                    clazz.getMethod("configure", Activity.class, String.class, String.class,
                        String[].class);
                method.invoke(null, activity, clientOptions, appId, zoneIds);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }
    }

    static void addNetworkExtrasBundle(AdRequest.Builder builder, String zoneId) {
        if (isLinkedWithAdColony()) {
            try {
                Class builderClass = Class.forName("com.jirbo.adcolony.AdColonyBundleBuilder");

                Method setZoneIdMethod = builderClass.getMethod("setZoneId", String.class);
                setZoneIdMethod.invoke(null, zoneId);

                Method buildMethod = builderClass.getMethod("build");
                Bundle extras = (Bundle) buildMethod.invoke(null);

                Class adapterClass = Class.forName("com.jirbo.adcolony.AdColonyAdapter");
                builder.addNetworkExtrasBundle(adapterClass, extras);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }
    }
}
