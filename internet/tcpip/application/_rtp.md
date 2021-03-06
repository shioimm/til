# RTP
- RealTime Transport Protocol
- UDPでリアルタイムなマルチメディア通信を実現するためプロトコル
  - UDPの代わりに通信の信頼性を保証する
  - 機能的にはトランスポートプロトコルではあるがアプリケーションプログラムとして実装される

### 動作の仕組み
- RTPはパケットにタイムスタンプとシーケンス番号を付加する
  - パケットを受け取ったアプリケーションは、タイムスタンプの時刻を元に再生するタイミングを調整する
  - シーケンス番号はパケットを一つ送るごとにインクリメントされる
  - シーケンス番号を使って同じタイムスタンプを持つデータを並び直したり、パケットの抜けを把握する

## RTCP
- RTP Control Protocol
- RTPによる通信を補助する
- パケット喪失率など通信回線の品質を管理することでRTPのデータ転送レートを制御する

## 参照
- マスタリングTCP/IP 入門編
