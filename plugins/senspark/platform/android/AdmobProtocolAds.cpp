#include "AdmobProtocolAds.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"
#include <sstream>

USING_NS_SENSPARK_PLUGIN_ADS;
using namespace cocos2d::plugin;
using namespace cocos2d;

AdmobProtocolAds::~AdmobProtocolAds() {
    PluginUtils::erasePluginJavaData(this);
}
