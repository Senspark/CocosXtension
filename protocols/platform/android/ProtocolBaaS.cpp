#include "ProtocolBaaS.h"
#include "PluginJniHelper.h"
#include <android/log.h>
#include "PluginUtils.h"
#include "PluginJavaData.h"

using namespace std;
namespace cocos2d { namespace plugin {

ProtocolBaaS::ProtocolBaaS() : _listener(nullptr) {

}

ProtocolBaaS::~ProtocolBaaS() {

}

void ProtocolBaaS::configDeveloperInfo(TBaaSDeveloperInfo devInfo) {
    if (devInfo.empty()) {
        PluginUtils::outputLog("ProtocolBaaS", "The developer info is empty for %s!", this->getPluginName());
        return;
    } else {
        PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
        PluginJniMethodInfo t;
        if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "configDeveloperInfo", "(Ljava/util/Hashtable;)V")) {
            jobject obj_Map = PluginUtils::createJavaMapObject(&devInfo);

            t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
            t.env->DeleteLocalRef(obj_Map);
            t.env->DeleteLocalRef(t.classID);
        }
    }
}

void ProtocolBaaS::signUp(map<string, string> userInfo) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "signUp", "(Ljava/util/Hashtable;)V")) {
        jobject obj_Map = PluginUtils::createJavaMapObject(&userInfo);

        t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
        t.env->DeleteLocalRef(obj_Map);
        t.env->DeleteLocalRef(t.classID);
    }
}

}}
