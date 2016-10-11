//
//  utility.hpp
//  PluginProtocol
//
//  Created by Zinge on 10/11/16.
//  Copyright © 2016 zhangbin. All rights reserved.
//

#ifndef SENSPARK_PLUGIN_X_UTILITY_HPP_
#define SENSPARK_PLUGIN_X_UTILITY_HPP_

#include <cstddef>
#include <string>
#include <vector>

namespace cocos2d {
namespace plugin {
class PluginProtocol;
class PluginParam;
} // namespace plugin
} // namespace cocos2d

namespace senspark {
namespace detail {
template <std::size_t... Is> struct sequence {
    static constexpr std::size_t arity = sizeof...(Is);
};

template <std::size_t N, std::size_t... Is>
struct sequence_generator : sequence_generator<N - 1, N - 1, Is...> {};

template <std::size_t... Is> struct sequence_generator<0, Is...> {
    using type = sequence<Is...>;
};

template <std::size_t N>
using make_sequence = typename sequence_generator<N>::type;

using cocos2d::plugin::PluginProtocol;
using cocos2d::plugin::PluginParam;

template <class ReturnType>
ReturnType callFunction(PluginProtocol* plugin, const std::string& functionName,
                        const std::vector<PluginParam*>& params);

template <class ReturnType, class... Args, std::size_t... Is>
ReturnType callFunction(PluginProtocol* plugin, const std::string& functionName,
                        sequence<Is...>, Args&&... args) {
    std::vector<PluginParam> params = {
        PluginParam{std::forward<Args>(args)}...};
    std::vector<PluginParam*> param_pointers = {&params.at(Is)...};
    return callFunction<ReturnType>(plugin, functionName, param_pointers);
}
} // namespace detail

template <class ReturnType = void, class... Args>
ReturnType callFunction(cocos2d::plugin::PluginProtocol* plugin,
                        const std::string& functionName, Args&&... args) {
    return detail::callFunction<ReturnType>(
        plugin, functionName, detail::make_sequence<sizeof...(Args)>(),
        std::forward<Args>(args)...);
}
} // namespace senspark

#endif /* SENSPARK_PLUGIN_X_UTILITY_HPP_ */
