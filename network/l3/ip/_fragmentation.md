# IPフラグメンテーション
## (前提)
- データリンクによってMTUが異なる
- IPはデータリンクごとのMTUの差異に左右されることなく利用できる必要がある

## パケットの分割・再構築
- IPデータグラムサイズが送信先のデータリンクのMTUよりも大きいという状況が発生する度、
  ノードは必要に応じてIPデータグラムを分割する
- 分割されたデータグラムはオフセットフィールドに元のデータグラム内での位置を持つ
- 分割されたデータグラムは終点ノードで再構築される(経路上のノードでは分割のみを行う)
- IPv4はパケット内にIPフラグメンテーションのためのフィールドを持つ
  - MFフラグ - 断片化された後続のパケットがあることを示すために利用
  - フラグメントオフセット - 断片化されているパケットの位置を表す・パケットの復元のために利用
- IPv6は拡張ヘッダであるフラグメントヘッダを追加することで断片化を行うことが可能
  - MTU探索の結果MTUを超えるパケットがある場合は送信元ホストが断片化を実施する

## 参照
- Linuxプログラミングインターフェース 58章
- Software Design 2021年5月号 ハンズオンTCP/IP
- マスタリングTCP/IP 入門編