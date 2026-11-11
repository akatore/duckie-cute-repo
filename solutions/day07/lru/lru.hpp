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

    std::optional<V> get(const K& key)
    {
        auto it = index_.find(key);
        if (it == index_.end())
            return std::nullopt;
        items_.splice(items_.begin(), items_, it->second);
        return it->second->second;
    }

    void put(const K& key, V value)
    {
        auto it = index_.find(key);
        if (it != index_.end()) {
            it->second->second = std::move(value);
            items_.splice(items_.begin(), items_, it->second);
            return;
        }
        if (capacity_ == 0)
            return;
        if (items_.size() == capacity_) {
            index_.erase(items_.back().first);
            items_.pop_back();
        }
        items_.emplace_front(key, std::move(value));
        index_[key] = items_.begin();
    }

    std::size_t size() const { return items_.size(); }

private:
    using Item = std::pair<K, V>;
    std::size_t capacity_;
    std::list<Item> items_;   // front = most recently used
    std::unordered_map<K, typename std::list<Item>::iterator> index_;
};
