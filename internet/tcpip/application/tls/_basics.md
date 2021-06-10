# SSL/TLS
- SSL(Secure socket layer)
  - クライアント-サーバー間で間で機密情報を送信するため、インターネット接続を安全に行う技術
- TLS(Transport layer security)
  - より安全なSSLの上位互換バージョン
- HTTPS (Hyper text transfer Protocol SECURE)
  - SSL/TLSで保護されたデータの転送に使用されるHTTPプロトコル(HTTP + SSL/TLS)

## 特徴
- [OSI参照モデル]セッション層で動作し、アプリケーション層のプロトコルと組み合わせて使用される
- [TCP/IPプロトコル]アプリケーション層で実装され、TCPの直接の上位層で動作する
  - アプリケーション層の動作に影響を与えることなくネットワーク通信時の安全性を提供する
- 433番ポートで受信したデータは暗号化されているとみなされ、
  受信側のSSLサーバーにて復号してアプリケーションに渡される
- 最も広く使用されているSSLライブラリはOpenSSL
  - その他LibreSSL、GnuTLS、NSS

### TLSが提供する機能
- ハイブリッド暗号方式による情報の内容の暗号化(盗聴対策)
- MAC関数による改竄検知(改竄対策)
- デジタル署名による通信相手の認証(なりすまし対策 / 否認対策)

## 全体概要
- Record + Handshake + ChangeCipherSpec + Alert + アプリケーション
  - Record - 暗号化されたアプリケーションデータをはじめ、SSL/TLSでやり取りされるデータを扱うプロトコル
  - Handshake - 共有状態を確立するためのプロトコル
  - ChangeCipherSpec - 暗号通信への切り替え通知のためのプロトコル
  - Alert - 異常通知のためのプロトコル

### 動作フロー
1. TCPコネクションを確立する
2. Handshakeによって通信相手とのセッションを確立する
3. ChangeCipherSpecによって平文の通信からHandshakeで合意した暗号アルゴリズムを用いる暗号通信へ切り替える
4. アプリケーションはRecordプロトコルを通じてレコード(アプリケーションデータ)のやりとりを行う
5. Alertによって異常の発生を通信相手に通知する
6. AlertによってSSL/TLSの終了を伝え、SSL/TLSセッションを終了する
7. TCPコネクションを切断する

## HTTP/2における仕様
- TLS1.2以上
- TLS SNIのサポート
- 圧縮機能無効化 -> HTTP/2自身が圧縮を行う
- 再ネゴシエーション禁止 -> クライアント証明書の要求はコネクションプリフェイス前に実行される必要がある
- 暗号スイート
  - `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`をサポート
  - 仕様で禁止されている暗号スイートの使用禁止

### 暗号スイートの条件が合わない場合
- `INADEQUEATE_SECURITY`エラーコネクションによって切断される場合がある -> コネクションエラー
  - ALPNネゴシエーションと暗号スイートの選択が独立して行われるため、
    暗号スイートの条件が一致しない場合がある

## 参照
- [How is data secure over https?](https://blog.joshsoftware.com/2019/08/23/how-is-data-secure-over-https/)
- よくわかるHTTP/2の教科書P18-20/124-125
- SSLをはじめよう ～「なんとなく」から「ちゃんとわかる！」へ～
- [図解で学ぶネットワークの基礎：SSL編](https://xtech.nikkei.com/it/article/COLUMN/20071002/283518/)
- ハイパフォーマンスブラウザネットワーキング
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
