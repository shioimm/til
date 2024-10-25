# キャッシュのTTLを知りたい (Redis)

```
irb(main):017> conn = Rails.cache.redis.checkout
=> #<Redis client v*.*.* for redis://...>

irb(main):019> conn.get(#{CACHE_KEY})

irb(main):020> conn.ttl(#{CACHE_KEY})
=> (残り秒数)
```
