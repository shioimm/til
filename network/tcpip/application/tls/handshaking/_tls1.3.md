# TLS 1.3 ハンドシェイク
1. クライアント -> サーバー
    - SYN
2. クライアント <- サーバー
    - ACK + SYN
3. クライアント -> サーバー
    - ACK
    - ClientHello
4. クライアント <- サーバー
    - ServerHello
    - EncryptedExtensions
    - Certificate
    - CertificateVerify
    - Finished
    - アプリケーションデータ
5. クライアント -> サーバー
    - Finished
    - アプリケーションデータ

#### ClientHello (クライアント)
- DH鍵共有のための秘密鍵情報 (KS: Key Share) 、事前鍵共有 (PSK: Pre Shared Key) を送信 (optional)

#### ServerHello (サーバー)
- DH鍵共有のための秘密鍵情報 (KS: Key Share) 、事前鍵共有 (PSK: Pre Shared Key) を送信
- 秘密鍵の共有が完了し移行暗号化通信へ移行

#### EncryptedExtensions (サーバー)
- 暗号化したサーバーパラメータを送信

#### Certificate (サーバー)
- 暗号化したサーバー証明書を送信

#### アプリケーションデータ (サーバー・クライアント)
- 認証処理が終わり次第暗号化されたアプリケーションデータを送信

#### Finished (サーバー・クライアント)
- 暗号化されたFinishedメッセージを送信

## 鍵導出関数 HKDF (HMAC-based Key Derivation Function)
- TLS1.3でハンドシェイク時に共有される秘密鍵を導出するアルゴリズムが新たに設計された
- HKDFは短いシードや補助入力から秘密鍵として利用できる複数の安全な疑似乱数を取得する関数
  - HKDF-Extract
  - HKDF-Expand

## 参照
- プロフェッショナルSSL/TLS
- 暗号技術入門 第3版
- パケットキャプチャの教科書
