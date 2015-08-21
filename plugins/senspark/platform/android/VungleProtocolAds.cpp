#include "VungleProtocolAds.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_ADS;
using namespace cocos2d::plugin;

VungleProtocolAds::VungleProtocolAds() {

}

VungleProtocolAds::~VungleProtocolAds() {
    PluginUtils::erasePluginJavaData(this);
}

void VungleProtocolAds::configureAds(const std::string& adsId) {
    TAdsDeveloperInfo devInfo;
    devInfo["VungleID"] = adsId;
    configDeveloperInfo(devInfo);
}

