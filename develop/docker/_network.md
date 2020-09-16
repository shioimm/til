# ネットワーキング
- 参照: [Docker コンテナ・ネットワークの理解](https://docs.docker.jp/engine/userguide/networking/dockernetworks.html)
- 参照: [Docker0 ブリッジのカスタマイズ](https://docs.docker.jp/engine/userguide/networking/default_network/custom-docker0.html)
- 参照: [Linuxカーネルのコンテナ機能［5］ ─ネットワーク](https://gihyo.jp/admin/serial/01/linux_containers/0006)
- 参照: [Docker Compose入門 (3) ～ネットワークの理解を深める～](https://knowledge.sakura.ad.jp/23899/)

## Network namespace
- コンテナでネットワークを使用する際Network Namespaceが作成される
- ホスト上に存在するネットワークインターフェースをネットワーク名前空間に割り当てる

```
Container Namespace  | Host Namespace
 container <-> eth0 <-> vethxxx <-> docker0 <-> eth0 <-> LAN
```

## docker0
- Dockerをインストールした際に作成されるブリッジネットワーク
- Dockerデーモンがデフォルトでコンテナを接続する

## veth
- Linuxが提供する仮想的なネットワークインターフェース
- vethインターフェースを作成すると、仮想NICのペアが作成される
  この2つの仮想NIC間で通信を行うことができる
  - 片方の仮想NICはコンテナのNetwork Namespaceに割り当てる(eth0)
  - もう片方の仮想NICはホストのNetwork Namespaceでdocker0と接続する(vethxxxx)

## eth0(Network namespace内)
- vethインターフェースによって作成された仮想NICのペアのうち、
  コンテナのNetwork Namespaceに割り当てられたもの
- vethを通してdocker0に接続されるとIPアドレスが配布される
- 別のコンテナのNetwork namespace内のeth0同士はIPアドレスを通じて通信を行うことができる

## `docker-compose`の場合
- `docker-compose`で起動されたコンテナはデフォルトのブリッジネットワークを使用せず
  `docker-compose`プロジェクト単位で専用のブリッジネットワークを持つ
  - デフォルトのブリッジネットワークとはIPアドレスのレンジが異なるため、通信を行うことができない

## ネットワークモード
### bridge
- Linuxのブリッジ機能を使うブリッジ・ネットワーク
- ホスト上にあるdocker0からコンテナ内のネットワーク(eth0)に対してIPアドレスが割り振られる
- コンテナ内からの通信はインターネット側にルーティングされる

### host
- コンテナがホスト側のネットワーク・インターフェースを共有する
- ホスト上のネットワーク(eth0)のIPアドレスをコンテナ内で利用する
- ホストとコンテナでネットワークが隔離されない
- コンテナ内でプログラムがポートをリッスンすると、そのままインターネット側と通信可能になる

### null
- コンテナにネットワーク・インターフェースを持たせない
- コンテナは内外での通信ができない

### overlay
- Dockerコンテナのマルチホスト間通信
