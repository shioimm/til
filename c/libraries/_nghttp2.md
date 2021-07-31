# nghttp2
- [nghttp2.org](https://nghttp2.org/)
- [nghttp2 / nghttp2](https://github.com/nghttp2/nghttp2)
- CによるHTTP/2実装

## h2load
- [h2load - HTTP/2 benchmarking tool - HOW-TO](https://nghttp2.org/documentation/h2load-howto.html)
- [h2load(1)](https://nghttp2.org/documentation/h2load.1.html)
- HTTP/2・HTTP/1.1対応のベンチマークツール
- HTTP/2の場合ALPNでネゴシエートされる

```
$ h2load -n100000 -c100 -m10 https://localhost

# -n - リクエスト数
# -c - 並列数
# -m - クライアントごとの最大同時ストリーム数
# -p - プロトコル
```
