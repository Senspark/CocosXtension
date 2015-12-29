#include "BaasboxProtocolBaaS.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"
#include "PluginJavaData.h"
#include <string>

USING_NS_SENSPARK_PLUGIN_BAAS;
using namespace cocos2d;
using namespace cocos2d::plugin;
using namespace std;

BaasboxProtocolBaaS::~BaasboxProtocolBaaS(){
	PluginUtils::erasePluginJavaData(this);
}

void BaasboxProtocolBaaS::loginWithFacebookToken(const std::string &facebookToken, BaaSCallback &cb){
	CallbackWrapper* wrapper = new CallbackWrapper(cb);
	PluginUtils::outputLog("BaasboxProtocol", "loginWithFacebookToken with facebookToken %s and callbackid %d.", facebookToken.c_str(), wrapper);
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "loginWithFacebookToken", "(Ljava/lang/String;J)V")){
		jstring strFacebookToken = PluginUtils::getEnv()->NewStringUTF(facebookToken.c_str());
		jlong jWrapper = (jlong) wrapper;

		// invoke java method
		t.env->CallVoidMethod(pData->jobj, t.methodID, strFacebookToken, jWrapper);
		t.env->DeleteLocalRef(strFacebookToken);
		t.env->DeleteLocalRef(t.classID);
	}
}

void BaasboxProtocolBaaS::updateUserProfile(const std::string &profile, BaaSCallback &cb){
	CallbackWrapper* wrapper = new CallbackWrapper(cb);
	PluginUtils::outputLog("BaasboxProtocol", "updateUserProfile with profile %s and callbackid %d.", profile.c_str(), wrapper);
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;
	if (PluginJniHelper::getMethodInfo(
			t
			, pData->jclassName.c_str()
			, "updateUserProfile"
			, "(Ljava/lang/String;J)V"))
	{
		jstring strProfile = PluginUtils::getEnv()->NewStringUTF(profile.c_str());
		jlong jWrapper = (jlong) wrapper;

		// invoke java method
		t.env->CallVoidMethod(pData->jobj, t.methodID, strProfile, jWrapper);
		t.env->DeleteLocalRef(strProfile);
		t.env->DeleteLocalRef(t.classID);
	}
}

void BaasboxProtocolBaaS::fetchUserProfile(BaaSCallback &cb){
	CallbackWrapper* wrapper = new CallbackWrapper(cb);
	PluginUtils::callJavaFunctionWithName_oneParam(this, "fetchUserProfile", "(J)V", (long) wrapper);
}

void BaasboxProtocolBaaS::fetchScoresFriendsFacebookWithPlayers(const std::string& players, BaaSCallback &cb){
	CallbackWrapper* wrapper = new CallbackWrapper(cb);
	PluginUtils::outputLog("BaasboxProtocol", "fetchScoresFriendsFacebookWithPlayers with plaers %s and callbackid %d.", players.c_str(), wrapper);
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;
	if (PluginJniHelper::getMethodInfo(
			t
			, pData->jclassName.c_str()
			, "fetchScoresFriendsFacebookWithPlayers"
			, "(Ljava/lang/String;J)V"))
	{
		jstring strPlayers = PluginUtils::getEnv()->NewStringUTF(players.c_str());
		jlong jWrapper = (jlong) wrapper;

		// invoke java method
		t.env->CallVoidMethod(pData->jobj, t.methodID, strPlayers, jWrapper);
		t.env->DeleteLocalRef(strPlayers);
		t.env->DeleteLocalRef(t.classID);
	}
}

