//
//  utility.hpp
//  PluginProtocol
//
//  Created by Zinge on 10/11/16.
//  Copyright © 2016 zhangbin. All rights reserved.
//

#ifndef SENSPARK_PLUGIN_X_UTILITY_HPP_
#define SENSPARK_PLUGIN_X_UTILITY_HPP_

#include <string>
#include <vector>

#include "senspark/integer_sequence.hpp"

namespace cocos2d {
namespace plugin {
class PluginProtocol;
class PluginParam;
} // namespace plugin
} // namespace cocos2d

namespace senspark {
namespace detail {
using cocos2d::plugin::PluginProtocol;
using cocos2d::plugin::PluginParam;

template <class ReturnType>
ReturnType callFunction(PluginProtocol* plugin, const std::string& functionName,
                        const std::vector<PluginParam*>& params);

template <class ReturnType, class... Args, std::size_t... Is>
ReturnType callFunction(PluginProtocol* plugin, const std::string& functionName,
                        index_sequence<Is...>, Args&&... args) {
    std::vector<PluginParam> params = {
        PluginParam{std::forward<Args>(args)}...};
    std::vector<PluginParam*> param_pointers = {&params.at(Is)...};
    return callFunction<ReturnType>(plugin, functionName, param_pointers);
}
} // namespace detail

template <class ReturnType = void, class... Args>
ReturnType callFunction(cocos2d::plugin::PluginProtocol* plugin,
                        const std::string& functionName, Args&&... args) {
    return detail::callFunction<ReturnType>(plugin, functionName,
                                            index_sequence_for<Args...>(),
                                            std::forward<Args>(args)...);
}
} // namespace senspark

#endif /* SENSPARK_PLUGIN_X_UTILITY_HPP_ */
