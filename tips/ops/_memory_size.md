# 消費メモリサイズを取得

```ruby
require 'objspace'

arr = [1, 2, 3]
ObjectSpace.memsize_of(arr) # バイト単位
```
