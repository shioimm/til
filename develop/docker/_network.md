# ネットワーキング
- 参照: [Docker コンテナ・ネットワークの理解](https://docs.docker.jp/engine/userguide/networking/dockernetworks.html)
- 参照: [Docker0 ブリッジのカスタマイズ](https://docs.docker.jp/engine/userguide/networking/default_network/custom-docker0.html)
- 参照: [Linuxカーネルのコンテナ機能［5］ ─ネットワーク](https://gihyo.jp/admin/serial/01/linux_containers/0006)
- 参照: [Docker Compose入門 (3) ～ネットワークの理解を深める～](https://knowledge.sakura.ad.jp/23899/)
- 参照: [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その5:Dockerのネットワークってどうなってるの？ 〜](https://tech-lab.sios.jp/archives/20179)

## ネットワーク構成種別
### bridge
- Linuxのブリッジ機能を使うブリッジ・ネットワーク
- ホスト上にあるブリッジからコンテナ内のネットワーク(eth0)に対してIPアドレスが割り振られる
- コンテナ内からの通信はインターネット側にルーティングされる

### host
- コンテナがホスト側のネットワーク・インターフェースを共有する
- ホスト上のネットワーク(eth0)のIPアドレスをコンテナ内で利用する
- ホストとコンテナでネットワークが隔離されない
- コンテナ内でプログラムがポートをlistenすると、そのままインターネット側と通信可能になる

### none
- コンテナにネットワーク・インターフェースを持たせない
- コンテナは内外での通信ができない

## 技術的要素
### Network namespace
- カーネルが提供する独立したネットワーク空間
- コンテナでネットワークを使用する際Network Namespaceが作成される
- ホスト上に存在するネットワークインターフェースをネットワーク名前空間に割り当てる

```
--------------------------- Host -------------------- | --------- Container --------
LAN <-> eth0(物理NIC) <-> docker0(ブリッジ) <-> veth <-> veth(仮想NIC) <-> container
```

### docker0(ブリッジ)
- 仮想スイッチ
- Dockerをインストールした際に作成されるブリッジネットワーク
- Dockerデーモンがデフォルトでコンテナを接続する

### veth
- Linuxが提供する仮想的なネットワークインターフェース
- vethインターフェースを作成すると、仮想NICのペアが作成される
  この2つの仮想NIC間で通信を行う
  - 片方の仮想NICはコンテナのNetwork Namespaceでeth0のように動作する
  - もう片方の仮想NICはホストのNetwork Namespaceでdocker0と接続する
    - vethインターフェースを通してdocker0に接続されるとIPアドレスが配布される
    - コンテナ同士はNetwork namespaceのIPアドレスを通じて通信を行う

## `docker-compose`の場合
- `docker-compose`で起動されたコンテナはデフォルトのブリッジネットワークを使用せず
  `docker-compose`プロジェクト単位で専用のブリッジネットワークを持つ
  - デフォルトのブリッジネットワークとはIPアドレスのレンジが異なるため、通信を行うことができない
