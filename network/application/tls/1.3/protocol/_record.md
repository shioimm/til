# Recordプロトコル
- 書式が不定のデータ (opaque data) を含んだメッセージの運搬、暗号化、保護を行う
- 実際の機能はRecordプロトコル以下のサブプロトコルによって実現される
- クライアントとサーバの間でやり取りされるTLSレコードを規定する

## レコードの暗号化
- TLS1.3ではTLSレコードのペイロードを保護して機密性と完全性を同時に確保するため、
  認証付き暗号 (AEAD) を利用する

```
// パラメータとしてnonce、平文、暗号化不要な付加的なデータ (完全性の検証のために含める)
AEADEncrypted = AEAD-Encrypt(write_key, nonce, plaintext, additional_data)

// nonceの生成のために通信の双方でそれぞれ保持している64ビット長のメッセージカウンタを利用する
// additional_data = TLSCiphertext.opaque_type || TLSCiphertext.legacy_record_version || TLSCiphertext.length
```

- TLS1.3では平文の長さは暗号化される

## TLSレコードフォーマット
- [ヘッダ] サブプロトコルの種類
- [ヘッダ] TLSプロトコルのバージョン番号
- [ヘッダ] ペイロードの長さ
- メッセージデータ (内容はサブプロトコルによって決定される / 上限値は16384バイト)

```c
// 暗号化前

struct {
  ContentType type;
  ProtocolVersion legacy_record_version; // 0x0303 (TLS 1.2 を表すダミー値): 実際には使われない
  uint16 length;
  opaque fragment[TLSPlaintext.length];
} TLSPlaintext;

enum {
  invalid(0),
  change_cipher_spec(20),
  alert(21),
  handshake(22),
  application_data(23),
  (255)
} ContentType;
```

```c
// 暗号化後

struct {
  ContentType opaque_type = application_data;      // 23: 実際には利用されない
  ProtocolVersion legacy_record_version = 0x0303;  // TLS v1.2
  uint16 length;
  opaque encrypted_record[TLSCiphertext.length];
} TLSCiphertext;

struct {
  opaque content[TLSPlaintext.length];
  ContentType type;
  uint8 zeros[length_of_padding]; // パディングを削除することでサブプロトコルを特定できるようになる
} TLSInnerPlaintext;

// メッセージは任意の長さのパディングに対応しており、メッセージ長を任意に増やすことが可能
// データを含まないメッセージにパディングを付加して中身のあるメッセージのように見せかけることも可能
```

# 参照
- プロフェッショナルSSL/TLS
