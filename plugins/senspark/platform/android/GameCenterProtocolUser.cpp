#include "GameCenterProtocolUser.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_USER;

using namespace cocos2d::plugin;

GameCenterProtocolUser::GameCenterProtocolUser() {

}

GameCenterProtocolUser::~GameCenterProtocolUser() {
    PluginUtils::erasePluginJavaData(this);
}
