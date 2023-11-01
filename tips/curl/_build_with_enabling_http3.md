#### HTTP/3を有効にしてビルドを行う

```
# Rustのインストール
$ curl https://sh.rustup.rs -sSf|sh

# cmakeのインストール
$ brew install cmake

# BoringSSLのビルド
$ git clone https://github.com/cloudflare/quiche --recursive
$ cd quiche
$ cargo build --release --features ffi,pkg-config-meta,qlog
$ mkdir deps/boringssl/src/lib
$ ln -vnf $(find target/release -name libcrypto.a -o -name libssl.a) deps/boringssl/src/lib/

# curlのビルド
$ cd ..
$ git clone https://github.com/curl/curl
$ cd curl
$ autoreconf -fi
$ ./configure LDFLAGS="-Wl,-rpath,$PWD/../quiche/target/release" --with-openssl=$PWD/../quiche/deps/boringssl/src --with-quiche=$PWD/../quiche/target/release
$ make
$ make install

$ ./src/curl https://google.com --http3 -v
```

## 参照
- [HTTP3 (and QUIC)](https://github.com/curl/curl/blob/master/docs/HTTP3.md)
- WEB+DB PRESS Vol.123 HTTP/3入門
