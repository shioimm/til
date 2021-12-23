# Alertプロトコル
- エラーの伝達や接続の終了を示す

```c
enum {
  warning(1),
  fatal(2),
  (255)
} AlertLevel;

enum {
  close_notify(0), // 暗号化のネゴシエーションがすでに実施されている
  unexpected_message(10),
  bad_record_mac(20),
  record_overflow(22),
  handshake_failure(40),
  bad_certificate(42),
  unsupported_certificate(43),
  certificate_revoked(44),
  certificate_expired(45),
  certificate_unknown(46),
  illegal_parameter(47),
  unknown_ca(48),
  access_denied(49),
  decode_error(50),
  decrypt_error(51),
  protocol_version(70),
  insufficient_security(71),
  internal_error(80),
  inappropriate_fallback(86),
  user_canceled(90), // ハンドシェイクが完了する前に接続が終了した
  missing_extension(109),
  unsupported_extension(110),
  unrecognized_name(112),
  bad_certificate_status_response(113),
  unknown_psk_identity(115),
  certificate_required(116),
  no_application_protocol(120),
  (255)
} AlertDescription;

struct {
  AlertLevel level; // TLS1.3では定義済みのメッセージはすべてfatal
  AlertDescription description; // 事前に定義されたメッセージの型を表す値
} Alert;
```

# 参照
- プロフェッショナルSSL/TLS
