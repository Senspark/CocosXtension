//
//  integer_sequence.hpp
//  PluginProtocol
//
//  Created by Zinge on 10/12/16.
//  Copyright © 2016 zhangbin. All rights reserved.
//

#ifndef SENSPARK_INTEGER_SEQUENCE_HPP_
#define SENSPARK_INTEGER_SEQUENCE_HPP_

#include <cstddef> // std::size_t

namespace senspark {
/// std::integer_sequence
/// http://en.cppreference.com/w/cpp/utility/integer_sequence
template <class T, T... Is> struct integer_sequence {
    using value_type = T;
    static constexpr std::size_t size() noexcept { return sizeof...(Is); }
};

/// std::index_sequence
template <std::size_t... Is>
using index_sequence = integer_sequence<std::size_t, Is...>;

namespace detail {
template <class T, T N, class Enabled = void, T... Is>
struct make_integer_sequence_impl
    : make_integer_sequence_impl<T, N - 1, Enabled, N - 1, Is...> {};

template <class T, T N, T... Is>
struct make_integer_sequence_impl<T, N, typename std::enable_if<N == 0>::type,
                                  Is...> {
    using type = integer_sequence<T, Is...>;
};
} // namespace detail

/// std::make_integer_sequence
template <class T, T N>
using make_integer_sequence =
    typename detail::make_integer_sequence_impl<T, N>::type;

/// std::make_index_sequence
template <std::size_t N>
using make_index_sequence = make_integer_sequence<std::size_t, N>;

/// std::index_sequence_for
template <class... Ts>
using index_sequence_for = make_index_sequence<sizeof...(Ts)>;
} // namespace senspark

#endif /* SENSPARK_INTEGER_SEQUENCE_HPP_ */
