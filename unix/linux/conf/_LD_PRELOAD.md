# `LD_PRELOAD`
- プログラム実行時、他のライブラリよりも優先して任意の共有ライブラリをロードさせるために利用される環境変数

```
FROM ruby:3.3-alpine

RUN apk update && \
    apk add --no-cache jemalloc

ENV LD_PRELOAD=/usr/lib/libjemalloc.so

...
```

## 参考
- [Ruby × jemallocのすすめ](https://tech.medpeer.co.jp/entry/ruby-jemalloc)
