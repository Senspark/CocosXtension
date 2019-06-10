# it is needed for ndk-r5
APP_PLATFORM := android-9
APP_STL := gnustl_static
APP_CPPFLAGS := -frtti -std=c++11 -fsigned-char
APP_MODULES := PluginProtocolStatic
APP_ABI := armeabi armeabi-v7a x86 arm64-v8a
#APP_ABI :=x86
#APP_ABI :=mips mips-r2 mips-r2-sf armeabi
