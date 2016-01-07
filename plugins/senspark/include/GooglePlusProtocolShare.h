//
//  GooglePlusProtocolShare.h
//  PluginSenspark
//
//  Created by Nikel Arteta on 1/7/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#ifndef GooglePlusProtocolShare_h
#define GooglePlusProtocolShare_h

#include "ProtocolShare.h"
#include "SensparkPluginMacros.h"
#include <string>
#include <map>
#include <vector>
#include <functional>

NS_SENSPARK_PLUGIN_SHARE_BEGIN

class GooglePlusProtocolShare : public cocos2d::plugin::ProtocolShare
{
public:
    typedef std::map<std::string, std::string> GPParam;

    GooglePlusProtocolShare();
    virtual ~GooglePlusProtocolShare();

    void share(GPParam& info, GooglePlusProtocolShare::ShareCallback& callback);

};

NS_SENSPARK_PLUGIN_SHARE_END

#endif /* GooglePlusProtocolShare_h */
