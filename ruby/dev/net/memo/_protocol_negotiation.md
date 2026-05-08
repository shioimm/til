# プロトコルネゴシエーション
## h2の場合

```text
クライアント                    DNS             サーバ
   |                             |                 |
   |--- A/AAAA クエリ ---------->|                 |
   |<-- IPアドレス --------------|                 |
   |                                               |
   |--- TCP SYN ---------------------------------->|
   |<-- TCP SYN-ACK -------------------------------|
   |--- TCP ACK ---------------------------------->|
   |                                               |
   |--- TLS ClientHello (ALPN: h2, http/1.1) ----->|
   |<-- TLS ServerHello (ALPN選択: h2) ------------|
   |    ... TLS ハンドシェイク完了 ...             |
   |                                               |
   |=== 以降HTTP/2 通信開始 =======================|
```

1. [クライアント] A/AAAA クエリを DNS に送信
2. [DNS] IP アドレスを返す
3. [クライアント] TCP SYN を送信
4. [サーバ] TCP SYN-ACK を返す
5. [クライアント] TCP ACK を送信
6. [クライアント] TLS ClientHello を送信 (ALPN: h2, http/1.1)
7. [サーバ] TLS ServerHello を返す (ALPN選択: h2) / TLS ハンドシェイク完了
8. 以降 HTTP/2 通信

## HTTPSレコードなし、h3の場合

```text
クライアント                    DNS                 サーバ
   |                             |                     |
   |--- A/AAAA クエリ ---------->|                     |
   |<-- IPアドレス --------------|                     |
   |                                                   |
   |--- TCP SYN -------------------------------------->|
   |<-- TCP SYN-ACK -----------------------------------|
   |--- TCP ACK -------------------------------------->|
   |                                                   |
   |--- TLS ClientHello (ALPN: h2, http/1.1) --------->|
   |<-- TLS ServerHello (ALPN選択: h2) ----------------|
   |    ... TLS ハンドシェイク完了 ...                 |
   |                                                   |
   |=== 以降HTTP/2 通信 ===============================|
   |                                                   |
   |<-- Alt-Svc: h3=":443"; max-age=86400 -------------|
   |                                                   |
   |    (Alt-Svc をキャッシュ)                         |
   |                                                   |
   |--- [QUIC Initial] CRYPTO: ClientHello ----------->|
   |      ALPN: h3                                     |
   |      quic_transport_params                        |
   |                                                   |
   |<-- [QUIC Initial] CRYPTO: ServerHello ------------|
   |<-- [QUIC Handshake] CRYPTO: EncryptedExtensions --|
   |                             Certificate           |
   |                             CertificateVerify     |
   |                             Finished              |
   |                                                   |
   |    (1-RTT 鍵を導出)                               |
   |                                                   |
   |--- [QUIC Handshake] CRYPTO: Finished ------------>|
   |                                                   |
   |=== 以降HTTP/3 通信 ===============================|
   |                                                   |
   |--- [QUIC 1-RTT] STREAM: HTTP/3 SETTINGS --------->|
   |--- [QUIC 1-RTT] STREAM: HTTP/3 リクエスト ------->|
   |                                                   |
   |<-- [QUIC 1-RTT] STREAM: HTTP/3 SETTINGS ----------|
   |<-- [QUIC 1-RTT] STREAM: HTTP/3 レスポンス --------|
```

1. [クライアント] A/AAAA クエリを DNS に送信
2. [DNS] IP アドレスを返す
3. [クライアント] TCP SYN を送信
4. [サーバ] TCP SYN-ACK を返す
5. [クライアント] TCP ACK を送信
6. [クライアント] TLS ClientHello を送信 (ALPN: h2, http/1.1)
7. [サーバ] TLS ServerHello を返す (ALPN選択: h2) / TLS ハンドシェイク完了
8. 以降 HTTP/2 通信
9. [サーバ] Alt-Svc: h3=":443"; max-age=86400 を返す
10. [クライアント] Alt-Svc をキャッシュ
11. [クライアント] [QUIC Initial] CRYPTO: ClientHello を送信 (ALPN: h3, quic_transport_params)
12. [サーバ] [QUIC Initial] CRYPTO: ServerHello を返す
13. [サーバ] [QUIC Handshake] CRYPTO: EncryptedExtensions / Certificate / CertificateVerify / Finished を返す
14. [クライアント] 1-RTT 鍵を導出
15. [クライアント] [QUIC Handshake] CRYPTO: Finished を送信
16. 以降 HTTP/3 通信
17. [クライアント] [QUIC 1-RTT] STREAM: HTTP/3 SETTINGS を送信（リクエストと並走可能）
18. [クライアント] [QUIC 1-RTT] STREAM: HTTP/3 リクエストを送信
19. [サーバ] [QUIC 1-RTT] STREAM: HTTP/3 SETTINGS を返す
20. [サーバ] [QUIC 1-RTT] STREAM: HTTP/3 レスポンスを返す

## HTTPSレコードあり、h3の場合 (HEv3なし)

```text
クライアント                    DNS                 サーバ
   |                             |                     |
   |--- A/AAAA + HTTPS クエリ -->|                     |
   |<-- IPアドレス               |                     |
   |    HTTPS RR: alpn="h3,h2"   |                     |
   |                                                   |
   |--- [QUIC Initial]   CRYPTO: ClientHello --------->|
   |      ALPN: h3                                     |
   |      quic_transport_params                        |
   |                                                   |
   |<-- [QUIC Initial]   CRYPTO: ServerHello ----------|
   |<-- [QUIC Handshake] CRYPTO: EncryptedExtensions --|
   |                             Certificate           |
   |                             CertificateVerify     |
   |                             Finished              |
   |                                                   |
   |    (1-RTT 鍵を導出)                               |
   |                                                   |
   |--- [QUIC Handshake] CRYPTO: Finished ------------>|
   |                                                   |
   |=== 以降 HTTP/3 通信 ==============================|
   |                                                   |
   |--- [QUIC 1-RTT] STREAM: HTTP/3 SETTINGS --------->|
   |--- [QUIC 1-RTT] STREAM: HTTP/3 リクエスト ------->|
   |                                                   |
   |<-- [QUIC 1-RTT] STREAM: HTTP/3 SETTINGS ----------|
   |<-- [QUIC 1-RTT] STREAM: HTTP/3 レスポンス --------|
```

1. [クライアント] A/AAAA + HTTPS クエリを DNS に送信
2. [DNS] IP アドレス + HTTPS RR (alpn="h3,h2") を返す
3. [クライアント] [QUIC Initial] CRYPTO: ClientHello を送信 (ALPN: h3, quic_transport_params)
4. [サーバ] [QUIC Initial] CRYPTO: ServerHello を返す
5. [サーバ] [QUIC Handshake] CRYPTO: EncryptedExtensions / Certificate / CertificateVerify / Finished を返す
6. [クライアント] 1-RTT 鍵を導出
7. [クライアント] [QUIC Handshake] CRYPTO: Finished を送信
8. 以降 HTTP/3 通信
9. [クライアント] [QUIC 1-RTT] STREAM: HTTP/3 SETTINGS を送信（リクエストと並走可能）
10. [クライアント] [QUIC 1-RTT] STREAM: HTTP/3 リクエストを送信
11. [サーバ] [QUIC 1-RTT] STREAM: HTTP/3 SETTINGS を返す
12. [サーバ] [QUIC 1-RTT] STREAM: HTTP/3 レスポンスを返す

## 検索用
- HTTPSRR
- HTTPSリソースレコード
- SVCB RR / SVCBRR
- HEv3
- Happy Eyeballs Version 3
