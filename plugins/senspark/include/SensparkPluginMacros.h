//
//  SensparkPluginMacros.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/20/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_SensparkPluginMacros_h
#define PluginSenspark_SensparkPluginMacros_h

#define NS_SENSPARK_PLUGIN_BEGIN    namespace senspark { namespace plugin {
#define NS_SENSPARK_PLUGIN_END      }}
#define USING_NS_SENSPARK_PLUGIN    using namespace senspark::plugin

#define NS_SENSPARK_PLUGIN_BEGIN_(X) namespace senspark { namespace plugin { namespace X {
#define NS_SENSPARK_PLUGIN_END_(X)   }}}
#define USING_NS_SENSPARK_PLUGIN_(X) using namespace senspark::plugin::X

#define NS_SENSPARK_PLUGIN_ANALYTICS_BEGIN  NS_SENSPARK_PLUGIN_BEGIN_(analytics)
#define NS_SENSPARK_PLUGIN_ANALYTICS_END    NS_SENSPARK_PLUGIN_END_(analytics)
#define USING_NS_SENSPARK_PLUGIN_ANALYTICS  USING_NS_SENSPARK_PLUGIN_(analytics)

#define NS_SENSPARK_PLUGIN_ADS_BEGIN        NS_SENSPARK_PLUGIN_BEGIN_(ads)
#define NS_SENSPARK_PLUGIN_ADS_END          NS_SENSPARK_PLUGIN_END_(ads)
#define USING_NS_SENSPARK_PLUGIN_ADS        USING_NS_SENSPARK_PLUGIN_(ads)

#define NS_SENSPARK_PLUGIN_SOCIAL_BEGIN     NS_SENSPARK_PLUGIN_BEGIN_(social)
#define NS_SENSPARK_PLUGIN_SOCIAL_END       NS_SENSPARK_PLUGIN_END_(social)
#define USING_NS_SENSPARK_PLUGIN_SOCIAL     USING_NS_SENSPARK_PLUGIN_(social)

#define NS_SENSPARK_PLUGIN_USER_BEGIN       NS_SENSPARK_PLUGIN_BEGIN_(user)
#define NS_SENSPARK_PLUGIN_USER_END         NS_SENSPARK_PLUGIN_END_(user)
#define USING_NS_SENSPARK_PLUGIN_USER       USING_NS_SENSPARK_PLUGIN_(user)

#define NS_SENSPARK_PLUGIN_SHARE_BEGIN      NS_SENSPARK_PLUGIN_BEGIN_(share)
#define NS_SENSPARK_PLUGIN_SHARE_END        NS_SENSPARK_PLUGIN_END_(share)
#define USING_NS_SENSPARK_PLUGIN_SHARE      USING_NS_SENSPARK_PLUGIN_(share)

#define NS_SENSPARK_PLUGIN_DATA_BEGIN      NS_SENSPARK_PLUGIN_BEGIN_(data)
#define NS_SENSPARK_PLUGIN_DATA_END        NS_SENSPARK_PLUGIN_END_(data)
#define USING_NS_SENSPARK_PLUGIN_DATA      USING_NS_SENSPARK_PLUGIN_(data)

#define NS_SENSPARK_PLUGIN_BAAS_BEGIN      NS_SENSPARK_PLUGIN_BEGIN_(baas)
#define NS_SENSPARK_PLUGIN_BAAS_END        NS_SENSPARK_PLUGIN_END_(baas)
#define USING_NS_SENSPARK_PLUGIN_BAAS      USING_NS_SENSPARK_PLUGIN_(baas)

#endif
