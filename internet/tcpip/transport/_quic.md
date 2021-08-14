# QUIC
- HTTP/3の基盤となるプロトコル
  - UDPを利用
    - UDP + QUICで一つのトランスポートプロトコルの役割を果たす

## 機能
- 認証・暗号化の提供
- 低遅延のコネクション管理
- 多重化
  - 1コネクションで複数のストリームを同時に扱う
- 再送処理
  - TCPよりもきめ細かくRTT時間を計測し、高精度な再送処理を行う
- ストリームレベルの再送制御とコネクションレベルのフロー制御
  - 一つのストリームでパケットの喪失が起きても他のストリームの通信は続く
  - ストリーム全体でフロー制御を行う
- コネクションのマイグレーション
  - IPアドレスが変わった場合もコネクションが維持されるようにする

## TCPに対する優位性
- HOLブロッキングの解消
- 接続確立までの時間を最小化
- 暗号化による硬直化の回避
- アップグレードの容易性

## 参照
- マスタリングTCP/IP 入門編
- [HTTP/3はどうやってWebを加速するか？ TCP、TLS、HTTP/2の問題とHTTP/3での解決策～Fastly奥氏が解説（前編）](https://www.publickey1.jp/blog/21/http3web_tcptlshttp2http3fastly.html)
- [HTTP/3はどうやってWebを加速するか？ TCP、TLS、HTTP/2の問題とHTTP/3での解決策～Fastly奥氏が解説（後編）](https://www.publickey1.jp/blog/21/http3web_tcptlshttp2http3fastly_1.html)
