# 遅延ACK
- ネットワークの利用効率を上げるためのメカニズム
  - 送信側は連続してセグメントを送信できる
  - 受信側はまとめて確認応答を行うことができる
- データサイズが小さいTCPセグメントに対する確認応答を少しだけ遅らせることによってACKの送信を減らす
  - 2 * MSSのデータを受信するまでACKしない
    - そうでない場合はACKを最大で0.5秒遅延させる(0.2秒程度のOSが一般的)

```
クライアント                                       サーバー
  送信 (シーケンス番号 1   / 200バイト) -----------> 受信 (シーケンス番号 1   / 200バイト)
  送信 (シーケンス番号 201 / 200バイト) -----------> 受信 (シーケンス番号 201 / 200バイト)
  送信 (シーケンス番号 401 / 200バイト) -----------> 受信 (シーケンス番号 401 / 200バイト)

  受信 (確認応答番号 601) <------------------------- 送信 (確認応答番号 601)
```

## 参照
- ハイパフォーマンスブラウザネットワーキング
- パケットキャプチャの教科書