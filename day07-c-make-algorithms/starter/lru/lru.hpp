#pragma once

#include <cstddef>
#include <list>
#include <optional>
#include <unordered_map>
#include <utility>

// Least-recently-used cache with O(1) get and put.
template <class K, class V>
class LruCache {
public:
    explicit LruCache(std::size_t capacity) : capacity_(capacity) {}

    // Returns the value and marks the key as most recently used, or std::nullopt.
    std::optional<V> get(const K& key)
    {
        // TODO: find in index_, move the node to the front with items_.splice, return the value
        (void)key;
        return std::nullopt;
    }

    // Inserts or updates; evicts the least recently used entry when full.
    void put(const K& key, V value)
    {
        // TODO: update existing (and move to front) or insert at front, evicting items_.back() if full
        (void)key;
        (void)value;
    }

    std::size_t size() const { return items_.size(); }

private:
    using Item = std::pair<K, V>;
    std::size_t capacity_;
    std::list<Item> items_;   // front = most recently used
    std::unordered_map<K, typename std::list<Item>::iterator> index_;
};
