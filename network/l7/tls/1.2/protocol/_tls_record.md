# TLS Recordプロトコル
- メッセージの圧出、暗号化、転送、認証を行うTLSのメインプロトコル
  - 共通鍵暗号 (ハイブリッド暗号) とMACを使用
  - 使用する共通鍵・アルゴリズムはHandshakeプロトコルレイヤでネゴシエーションを行うことによって決定される
  - データ転送と暗号処理以外の機能はTLS Recordプロトコル以外のサブプロトコルによって行う (TLSの拡張)
  - 圧縮機能は現在使用されていない (2012年にCRIME攻撃に利用された)

## 動作フロー
1. メッセージを複数の小さなフラグメントに分割し圧縮
    - 圧縮アルゴリズムはネゴシエーションで決定する
2. フラグメントにMACを付加
    - ハッシュ関数アルゴリズムと共通鍵はネゴシエーションで決定する
3. 圧縮したフラグメントとMACを合わせて暗号化 (CBCモード)
  　- 暗号化アルゴリズムと共通鍵はネゴシエーションで決定する
4. `3`にヘッダ(データタイプ・バージョン番号・圧縮した長さ)を追加して送信

## TLSレコードフォーマット
- コンテントタイプ
- プロトコルバージョン
- ペイロード長
- ペイロード

```c
struct {
  uint8 major;
  uint8 minor;
} ProtocolVersion;

enum {
  change_cipher_spec (20),
  alert              (21),
  handshake          (22),
  application_data   (23)
} ContentType;

struct {
  ContentType     type;
  ProtocolVersion version;
  uint16          length;                         // 最長 2^14 (16,384) バイト
  opaque          fragment[TLSPlaintext.length];  // 書式が定まっていない(opaque)データのバッファ
} TLSPlaintext;

// その他に64ビットのシーケンス番号が割り当てられる
```

- 最大レコードサイズは16KB
  - 16KBよりも大きいバッファは小さなチャンクへと分割される
  - 16KBよりも小さいバッファは複数のバッファから単一のレコードにまとめられる
  - 各レコードは5バイトのヘッダ、32バイトのMAC、ブロック暗号利用時はパディングが付与される
- 暗号を解読してレコードを検証するためにはレコード全体が必要となる

#### コンテントタイプ

| タイプ               | タイプコード | 意味                                 |
| -                    | -            | -                                    |
| `handshake`          | 22           | TLSハンドシェイクのためのレコード    |
| `change_cipher_spec` | 20           | 暗号仕様変更のためのレコード         |
| `alert`              | 21           | エラー通知のためのレコード           |
| `application_data`   | 23           | アプリケーションデータを表すレコード |

## 参照
- プロフェッショナルSSL/TLS
- 暗号技術入門 第3版
- パケットキャプチャの教科書
