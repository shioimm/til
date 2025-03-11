# TLS1.3
## 改善点
- ネットワーク遅延の削減 (1RTTでハンドシェイクが完了する)
- 鍵交換の見直し
  - すべての暗号スイートがPFSに対応
  - DHE (Ephemeral Diffie-Hellman) / ECDHE (Ephemeral Elliptic Curve Diffie-Hellman) のいずれかを使用
- 暗号化されずに送信される情報の削減 (サーバのホスト名以外はすべての箇所を暗号化可能)
- 暗号の要素技術の刷新

## 参照
- プロフェッショナルSSL/TLS
