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

namespace cocos2d { namespace plugin {

extern "C" {
JNIEXPORT void JNICALL Java_org_cocos2dx_plugin_PlatformWrapper_nativeOnPlatformResult(JNIEnv* env, jobject thiz, jint code, jstring msg)
{
	std::string strMsg 			= PluginJniHelper::jstring2string(msg);
	PluginProtocol* pPlugin 	= PluginUtils::getPluginPtr("ProtocolPlatform");
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

}

ProtocolPlatform::~ProtocolPlatform() {

}

bool ProtocolPlatform::isAppInstalled(const std::string& url) {
	return PluginUtils::callJavaBoolFuncWithName_oneParam(this, "isAppInstalled", "(Ljava/lang/String;)Z", url.c_str());
}

bool ProtocolPlatform::isConnected(const std::string& hostName) {
	return PluginUtils::callJavaBoolFuncWithName_oneParam(this, "isConnected", "(Ljava/lang/String;)Z", hostName.c_str());
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
	PluginUtils::callJavaFunctionWithName_oneParam(this, "sendFeedback", "(Ljava/lang/String;)V", appName.c_str());
}


}  // namespace plugin
}  // namespace cocos2d











