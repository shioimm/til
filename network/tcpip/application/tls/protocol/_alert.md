# Alertプロトコル
- 異常通知・接続終了のためのプロトコル
- 通信中の相手に例外的な状況を伝える

## Alertレコード定義

```c
struct {
  AlertLevel level;
  AlertDescription description;
} Alert;

// 接続終了時はどちらかのピアがclose_notifyアラートを送信する
```

## 参照
- プロフェッショナルSSL/TLS
- 暗号技術入門 第3版
- パケットキャプチャの教科書
