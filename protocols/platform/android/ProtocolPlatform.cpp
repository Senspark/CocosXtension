/****************************************************************************
Copyright (c) 2012-2013 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "ProtocolPlatform.h"
#include "PluginJniHelper.h"
#include <android/log.h>
#include "PluginUtils.h"
#include "PluginJavaData.h"
#include "PluginParam.h"

#define PROTOCOL_NAME                     "ProtocolPlatform"
#define ANDROID_PLUGIN_PACKAGE_PREFIX			"org/cocos2dx/plugin/"

namespace cocos2d { namespace plugin {

extern "C" {
JNIEXPORT void JNICALL Java_org_cocos2dx_plugin_PlatformWrapper_nativeOnPlatformResult(JNIEnv* env, jobject thiz, jint code, jstring msg)
{
	std::string strMsg 			= PluginJniHelper::jstring2string(env, msg);
  std::string jClassName = ANDROID_PLUGIN_PACKAGE_PREFIX;
  jClassName.append(PROTOCOL_NAME);

	PluginProtocol* pPlugin 	= PluginUtils::getPluginPtr(jClassName);
    PluginUtils::outputLog("PlatformWrapper", "pPlugin is null? - %s", pPlugin == nullptr? "YES":"NO");
	ProtocolPlatform* pPlatform = dynamic_cast<ProtocolPlatform*>(pPlugin);
	if (pPlatform != nullptr) {
		ProtocolPlatform::PlatformCallback callback = pPlatform->getCallback();
		if (callback) {
			callback((PlatformResultCode)code, strMsg);
		} else {
			PluginUtils::outputLog("PlatformWrapper", "Cannot find callback of plugin %s", pPlugin->getPluginName());
		}
	} else {
		PluginUtils::outputLog("PlatformWrapper", "Listener for plugin %s not set correctly", pPlugin->getPluginName());
	}
}
}

ProtocolPlatform::ProtocolPlatform() {

    std::string jClassName = ANDROID_PLUGIN_PACKAGE_PREFIX;
    jClassName.append(PROTOCOL_NAME);
    PluginUtils::outputLog("PluginFactory", "jClassName: %s", jClassName.c_str());
    PluginUtils::outputLog("PluginFactory", "Java class name of ProtocolPlatform : %s", jClassName.c_str());

    PluginJniMethodInfo t;
    if (! PluginJniHelper::getStaticMethodInfo(t
                                               , "org/cocos2dx/plugin/PluginWrapper"
                                               , "initPlugin"
                                               , "(Ljava/lang/String;)Ljava/lang/Object;"))
    {
        PluginUtils::outputLog("PluginFactory", "Can't find method initPlugin in class org.cocos2dx.plugin.PluginWrapper");
        return;
    }

    jstring clsName = t.env->NewStringUTF(jClassName.c_str());
    jobject jObj = t.env->CallStaticObjectMethod(t.classID, t.methodID, clsName); //ProtocolPlatform java object
    t.env->DeleteLocalRef(clsName);
    t.env->DeleteLocalRef(t.classID);

    ((PluginProtocol*) this)->setPluginName(PROTOCOL_NAME);
    PluginUtils::initJavaPlugin(this, jObj, jClassName.c_str());
}

ProtocolPlatform::~ProtocolPlatform() {

}

bool ProtocolPlatform::isAppInstalled(const std::string& url) {
    PluginParam param(url.c_str());

    return callBoolFuncWithParam("isAppInstalled", &param, nullptr);
}

bool ProtocolPlatform::isConnected(const std::string& hostName) {
    PluginParam param(hostName.c_str());

    return callBoolFuncWithParam("isConnected", &param, nullptr);
}

bool ProtocolPlatform::isRelease() {
  return callBoolFuncWithParam("isRelease", nullptr);
}

std::string ProtocolPlatform::getSHA1CertFingerprint() {
  return callStringFuncWithParam("getSHA1CertFingerprint", nullptr);
}

double ProtocolPlatform::getVersionCode() {
  return callDoubleFuncWithParam("getVersionCode", nullptr);
}

void ProtocolPlatform::sendFeedback(const std::string& appName) {
    PluginParam param(appName.c_str());

    callFuncWithParam("sendFeedback", &param, nullptr);
}

bool ProtocolPlatform::isTablet() {
    return callBoolFuncWithParam("isTablet", nullptr);
}

}  // namespace plugin
}  // namespace cocos2d



