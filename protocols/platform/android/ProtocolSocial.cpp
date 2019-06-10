/****************************************************************************
Copyright (c) 2013 cocos2d-x.org

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
#include "ProtocolSocial.h"
#include "PluginJniHelper.h"
#include <android/log.h>
#include "PluginUtils.h"
#include "PluginJavaData.h"
#include <string>

namespace cocos2d { namespace plugin {

extern "C" {
    JNIEXPORT void JNICALL Java_org_cocos2dx_plugin_SocialWrapper_nativeOnSocialResult(JNIEnv*  env, jobject thiz, jstring className, jboolean ret, jstring msg, jlong cbID)
    {
        std::string strMsg = PluginJniHelper::jstring2string(env, msg);
        std::string strClassName = PluginJniHelper::jstring2string(env, className);
        PluginProtocol* pPlugin = PluginUtils::getPluginPtr(strClassName);
        PluginUtils::outputLog("ProtocolSocial", "nativeOnSocialResult(), Get plugin ptr : %p", pPlugin);
        if (pPlugin != NULL)
        {
        	PluginUtils::outputLog("ProtocolSocial", "nativeOnSocialResult(), Get plugin name : %s", pPlugin->getPluginName());
        	ProtocolSocial* pSocial = dynamic_cast<ProtocolSocial*>(pPlugin);
        	if (pSocial != NULL && cbID)
        	{
        		ProtocolSocial::CallbackWrapper* wrapper = (ProtocolSocial::CallbackWrapper*) cbID;
        		PluginUtils::outputLog("ProtocolSocial", "Wrapper: %p", wrapper);
        		PluginUtils::outputLog("ProtocolSocial", "cbID : %p", cbID);

        		wrapper->callbackSocialPtr(ret, strMsg);
        		PluginUtils::outputLog("ProtocolSocial", "End", cbID);
        		delete wrapper;
        	} else {
        		PluginUtils::outputLog("Listener of plugin %s not set correctly", pPlugin->getPluginName());
            }
        }
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_plugin_SocialWrapper_nativeOnDialogDismissed(JNIEnv*  env, jobject thiz, jlong cbID)
    {
        PluginUtils::outputLog("ProtocolSocial", "nativeOnDialogDismissed()");
        if (cbID)
        {
            ProtocolSocial::CallbackWrapper* wrapper = (ProtocolSocial::CallbackWrapper*) cbID;

            wrapper->callbackDialogPtr();
            delete wrapper;
        } else {
            PluginUtils::outputLog("ProtocolSocial", "No callback");
        }
    }
}

ProtocolSocial::ProtocolSocial()
{
}

ProtocolSocial::~ProtocolSocial()
{
}

void ProtocolSocial::configDeveloperInfo(TSocialInfo devInfo)
{
    if (devInfo.empty())
    {
        PluginUtils::outputLog("ProtocolSocial", "The developer info is empty!");
        return;
    }
    else
    {
        PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
        PluginJniMethodInfo t;
        if (PluginJniHelper::getMethodInfo(t
            , pData->jclassName.c_str()
            , "configDeveloperInfo"
            , "(Ljava/util/Hashtable;)V"))
        {
            // generate the hashtable from map
            jobject obj_Map = PluginUtils::createJavaMapObject(&devInfo);

            // invoke java method
            t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
            t.env->DeleteLocalRef(obj_Map);
            t.env->DeleteLocalRef(t.classID);
        }
    }
}

void ProtocolSocial::submitScore(const std::string& leadboardID, int score, const SocialCallback& cb)
{
    PluginUtils::outputLog("ProtocolSocial", "Submit %l to leader board %s.", score, leadboardID.c_str());
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t
        , pData->jclassName.c_str()
        , "submitScore"
        , "(Ljava/lang/String;II)V"))
    {
        jstring strID = PluginUtils::getEnv()->NewStringUTF(leadboardID.c_str());
        jlong jscore = (jlong) score;
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

        // invoke java method
        t.env->CallVoidMethod(pData->jobj, t.methodID, strID, score, (jlong) cbWrapper);
        t.env->DeleteLocalRef(strID);
        t.env->DeleteLocalRef(t.classID);
    }
}

void ProtocolSocial::showLeaderboard(const std::string& leaderboardID, const DialogCallback& cb)
{
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t
        , pData->jclassName.c_str()
        , "showLeaderboard"
        , "(Ljava/lang/String;I)V"))
    {
        jstring strID = PluginUtils::getEnv()->NewStringUTF(leaderboardID.c_str());
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
        // invoke java method
        t.env->CallVoidMethod(pData->jobj, t.methodID, strID, (jlong) cbWrapper);
        t.env->DeleteLocalRef(strID);
        t.env->DeleteLocalRef(t.classID);
    }
}

void ProtocolSocial::showLeaderboards(const DialogCallback& cb) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	    PluginJniMethodInfo t;
	    if (PluginJniHelper::getMethodInfo(t
	        , pData->jclassName.c_str()
	        , "showLeaderboards"
	        , "(I)V"))
	    {
	    	CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
	        // invoke java method
	        t.env->CallVoidMethod(pData->jobj, t.methodID, (jlong) cbWrapper);
	        t.env->DeleteLocalRef(t.classID);
	    }
}

void ProtocolSocial::unlockAchievement(TAchievementInfo achInfo, const SocialCallback& cb)
{
    
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t
        , pData->jclassName.c_str()
        , "unlockAchievement"
        , "(Ljava/util/Hashtable;I)V"))
    {
        // generate the hashtable from map
        jobject obj_Map = PluginUtils::createJavaMapObject(&achInfo);
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
        // invoke java method
        t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map, (jlong) cbWrapper);
        t.env->DeleteLocalRef(obj_Map);
        t.env->DeleteLocalRef(t.classID);
    }
}

void ProtocolSocial::resetAchievements(const SocialCallback& cb)
{

    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t
                                       , pData->jclassName.c_str()
                                       , "resetAchievements"
                                       , "(I)V"))
    {
        // generate the hashtable from map
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
        // invoke java method
        t.env->CallVoidMethod(pData->jobj, t.methodID, (jlong) cbWrapper);
        t.env->DeleteLocalRef(t.classID);
    }
}

void ProtocolSocial::showAchievements(const DialogCallback& cb)
{
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
		    PluginJniMethodInfo t;
		    if (PluginJniHelper::getMethodInfo(t
		        , pData->jclassName.c_str()
		        , "showAchievements"
		        , "(I)V"))
		    {
		    	CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
		        // invoke java method
		        t.env->CallVoidMethod(pData->jobj, t.methodID, (jlong) cbWrapper);
		        t.env->DeleteLocalRef(t.classID);
		    }
}

}} // namespace cocos2d { namespace plugin {
