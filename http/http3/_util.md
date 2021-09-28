# 便利
- [curl with HTTP/3](https://github.com/unasuke/curl-http3/pkgs/container/curl-http3)
  - [HTTP/3が喋れるcurlを定期的にbuildする](https://blog.unasuke.com/2021/curl-http3-daily-build/)
  - [curlのHTTP/3実験実装を触ってみる](https://asnokaze.hatenablog.com/entry/2019/08/07/031904)

```
$ docker pull ghcr.io/unasuke/curl-http3:quiche-latest
$ docker run -it --rm ghcr.io/unasuke/curl-http3:quiche-latest bash
root@bdd5d7b0c697:/# curl --http3 -v https://quic.tech:8443
```

```
$ docker pull ghcr.io/unasuke/curl-http3:ngtcp2-latest
$ docker run -it --rm ghcr.io/unasuke/curl-http3:ngtcp2-latest bash
root@bdd5d7b0c697:/# curl --http3 -v https://quic.tech:8443
```
