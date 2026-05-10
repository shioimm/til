# DoT (DNS over TLS / DNS over DTLS) / DoH (DNS over HTTPS) / DoQ (DNS over QUIC)
- 平文のDNSトラフィックを暗号化するための規格

#### DoT / DoH / DoQを利用するかどうかの判断
- アプリケーションによる動作 (ブラウザなど)
- OS / スタブリゾルバによるデフォルトあるいは設定による動作

#### クライアントがフルリゾルバを選択する経路
- [IPv4] DHCP (DHCPv4) / [IPv6] RA (RDNSSオプション)
- ユーザ設定
- VPN
- OSによる動作
- ブラウザによる動作


## DoT (DNS over TLS / DNS over DTLS)
- DNS over TLS - TCP + TLS上でDNSクエリを送信する
- DNS over DTLS - UDP + DTLS上でDNSクエリを送信する
- DoT用ポート853を使用する
- TLSによってクライアント (スタブリゾルバ) とフルリゾルバ間のDNS問い合わせ・応答を暗号化する

```text
スタブリゾルバ                             フルリゾルバ (ポート853)
   |                                               |
   |--- TCP SYN ---------------------------------->|
   |<-- TCP SYN-ACK -------------------------------|
   |--- TCP ACK ---------------------------------->|
   |                                               |
   |--- TLS ClientHello -------------------------->|
   |<-- TLS ServerHello ---------------------------|
   |<-- EncryptedExtensions------------------------|
   |<-- Certificate -------------------------------|
   |<-- CertificateVerify -------------------------|
   |<-- Finished ----------------------------------|
   |--- Finished --------------------------------->|
   |    ... TLS ハンドシェイク完了 ...             |
   |                                               |
   |--- DNS問い合わせ (TLS暗号化) ----------------->|
   |<-- DNS応答 (TLS暗号化) -----------------------|
   |                                               |
   |    (接続維持または切断)                       |
```

1. [スタブリゾルバ] TCP SYNを送信する
2. [フルリゾルバ] TCP SYN-ACKを返す
3. [スタブリゾルバ] TCP ACKを送信する
4. [スタブリゾルバ] TLS ClientHelloを送信する
5. [フルリゾルバ] TLS ServerHello / EncryptedExtensions / Certificate / CertificateVerify / Finished を返す
6. [スタブリゾルバ] Finished を送信する
7. --- TLSハンドシェイク完了 ---
8. [スタブリゾルバ] DNS問い合わせを送信する
9. [フルリゾルバ] DNS応答を返す
10. 接続を維持するか切断する

## DoH (DNS over HTTPS)
- HTTPS上でDNSクエリを送信する
- HTTPS用ポート443を使用する

```text
スタブリゾルバ                                   フルリゾルバ (ポート443)
   |                                                    |
   |--- TCP SYN --------------------------------------->|
   |<-- TCP SYN-ACK ------------------------------------|
   |--- TCP ACK --------------------------------------->|
   |                                                    |
   |--- TLS ClientHello (ALPN: h2, http/1.1) ---------->|
   |<-- TLS ServerHello (ALPN選択: h2) -----------------|
   |<-- EncryptedExtensions ----------------------------|
   |<-- Certificate ------------------------------------|
   |<-- CertificateVerify ------------------------------|
   |<-- Finished ---------------------------------------|
   |--- Finished -------------------------------------->|
   |    ... TLS ハンドシェイク完了 ...                  |
   |                                                    |
   |--- HTTP/2 POST DNS問い合わせ --------------------->|
   |    Content-Type: application/dns-message           |
   |                                                    |
   |<-- HTTP/2 200 OK DNS応答 --------------------------|
   |    Content-Type: application/dns-message           |
   |                                                    |
   |    (接続維持または切断)                            |
```

1. [スタブリゾルバ] TCP SYNを送信する
2. [フルリゾルバ] TCP SYN-ACKを返す
3. [スタブリゾルバ] TCP ACKを送信する
4. [スタブリゾルバ] TLS ClientHelloを送信する (ALPN: h2, http/1.1)
5. [フルリゾルバ] TLS ServerHello (ALPN選択: h2) / EncryptedExtensions / Certificate / CertificateVerify / Finished
   を返す
6. [スタブリゾルバ] Finishedを送信する
7. --- TLSハンドシェイク完了 ---
8. [スタブリゾルバ] HTTP/2 POSTでDNS問い合わせを送信する (Content-Type: application/dns-message)
9. [フルリゾルバ] HTTP/2 200 OKを返す (Content-Type: application/dns-message)
10. 接続を維持するか切断する

## DoQ (DNS over QUIC)
- QUIC上でDNSクエリを送信する
- DoQ用ポート853を使用する

```text
スタブリゾルバ                                   フルリゾルバ (ポート853)
   |                                                    |
   |--- [QUIC Initial] CRYPTO: ClientHello ----------->|
   |    ALPN: doq                                      |
   |    quic_transport_params                          |
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
   |    ... QUIC ハンドシェイク完了 ...                |
   |                                                   |
   |--- [QUIC 1-RTT] STREAM: DNS クエリ -------------->|
   |<-- [QUIC 1-RTT] STREAM: DNS 応答 -----------------|
   |                                                   |
   |    (接続維持または切断)                           |
```

1. [スタブリゾルバ] [QUIC Initial] CRYPTO: ClientHelloを送信する (ALPN: doq / quic_transport_params)
2. [フルリゾルバ] [QUIC Initial] CRYPTO: ServerHelloを返す
3. [フルリゾルバ] [QUIC Handshake] CRYPTO: EncryptedExtensions / Certificate / CertificateVerify / Finishedを返す
4. [スタブリゾルバ] 1-RTT 鍵を導出する
5. [スタブリゾルバ] [QUIC Handshake] CRYPTO: Finishedを送信する
6. --- QUICハンドシェイク完了 ---
7. [スタブリゾルバ] [QUIC 1-RTT] STREAM: DNS問い合わせを送信する
8. [フルリゾルバ] [QUIC 1-RTT] STREAM: DNS応答を返す
9. 接続を維持するか切断する

## 参照
- [DoH/DoT入門](https://www.nic.ad.jp/ja/materials/iw/2019/proceedings/d3/d3-yamaguchi.pdf)
