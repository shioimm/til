# DCCP
- Datagram Congestion Control Protocol
- UDPを補完するプロトコル
- データの到達性や順序の維持を保証しない (UDPと同様)
- コネクション型でコネクションの確立と切断には信頼性を持つ
- ネットワークの混雑状況に合わせた輻輳制御を行うことができる
  - TCPライクな輻輳制御とTCPフレンドリーなレート制御のいずれかを選択可能
- 輻輳制御機能を持つ (パケットを受信した側はACKを返す)

## 参照
- マスタリングTCP/IP 入門編