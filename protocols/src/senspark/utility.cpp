//
//  utility.cpp
//  PluginProtocol
//
//  Created by Zinge on 10/11/16.
//  Copyright © 2016 zhangbin. All rights reserved.
//

#include "senspark/utility.hpp"
#include "PluginProtocol.h"

namespace senspark {
namespace detail {
template <>
void callFunction(PluginProtocol* plugin, const std::string& functionName,
                  const std::vector<PluginParam*>& params) {
    plugin->callFuncWithParam(functionName.c_str(), params);
}

template <>
int callFunction(PluginProtocol* plugin, const std::string& functionName,
                 const std::vector<PluginParam*>& params) {
    return plugin->callIntFuncWithParam(functionName.c_str(), params);
}

template <>
bool callFunction(PluginProtocol* plugin, const std::string& functionName,
                  const std::vector<PluginParam*>& params) {
    return plugin->callBoolFuncWithParam(functionName.c_str(), params);
}
} // namespace detail
} // namespace senspark
