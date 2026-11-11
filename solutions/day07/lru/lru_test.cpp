#include <iostream>
#include <string>

#include <lru.hpp>

static int failures = 0;

#define CHECK(cond)                                                        \
    do {                                                                   \
        if (!(cond)) {                                                     \
            ++failures;                                                    \
            std::cerr << __FILE__ << ":" << __LINE__ << ": CHECK failed: " \
                      << #cond << "\n";                                    \
        }                                                                  \
    } while (0)

int main()
{
    LruCache<std::string, int> cache(2);
    CHECK(!cache.get("a").has_value());

    cache.put("a", 1);
    cache.put("b", 2);
    CHECK(cache.get("a") == 1);          // a is now most recent
    cache.put("c", 3);                   // evicts b
    CHECK(!cache.get("b").has_value());
    CHECK(cache.get("a") == 1);
    CHECK(cache.get("c") == 3);
    CHECK(cache.size() == 2);

    cache.put("a", 10);                  // update moves a to the front
    cache.put("d", 4);                   // evicts c
    CHECK(cache.get("a") == 10);
    CHECK(!cache.get("c").has_value());
    CHECK(cache.get("d") == 4);
    CHECK(cache.size() == 2);

    LruCache<int, std::string> none(0);
    none.put(1, "x");
    CHECK(none.size() == 0);
    CHECK(!none.get(1).has_value());

    LruCache<int, int> big(1000);
    for (int i = 0; i < 100000; ++i)
        big.put(i, i * 2);
    CHECK(big.size() == 1000);
    CHECK(big.get(99999) == 199998);
    CHECK(!big.get(98999).has_value());
    CHECK(big.get(99000) == 198000);

    if (failures) {
        std::cerr << failures << " checks FAILED\n";
        return 1;
    }
    std::cout << "LRU: all checks passed\n";
    return 0;
}
