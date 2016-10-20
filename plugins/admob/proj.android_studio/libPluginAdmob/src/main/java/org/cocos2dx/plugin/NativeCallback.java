package org.cocos2dx.plugin;

import android.support.annotation.NonNull;

/**
 * Created by Zinge on 10/19/16.
 */

public abstract class NativeCallback {
    public abstract void onEvent(@NonNull Integer code, @NonNull String message);
}
