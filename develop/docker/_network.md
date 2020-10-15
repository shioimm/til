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

## 構成要素
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

### 仮想NICペア
- 片方の仮想NICはコンテナのNetwork Namespaceでeth0のように動作する
- もう片方の仮想NICはホストのNetwork Namespaceでdocker0と接続する
  - vethインターフェースを通してdocker0に接続されるとIPアドレスが配布される
  - コンテナ同士はNetwork namespaceのIPアドレスを通じて通信を行う

#### veth
- Linuxが提供する仮想的なネットワークインターフェース
- vethインターフェースを作成すると、仮想NICのペアが作成される
  この2つの仮想NIC間で通信を行う

## ネットワークの作成
1. Network Namespaceの作成
    - `$ ip netns add [Network Namespace名]`
2. ブリッジの作成
    - `$ ip link add [ブリッジ名] type bridge`
3. 仮想NICペアの作成
    - ルーター <-> ブリッジ / ブリッジ <-> Network Namespace内
    - `$ ip link add name veth [仮想NIC名] type veth peer name [対向の仮想NIC名]`
4. Network Namespace - Network Namespace側仮想NIC間の接続
    - `$ ip link set [仮想NIC名] netns [Network Namespace名]`
5. ブリッジ - ブリッジ側仮想NIC間の接続
    - `$ ip link set dev [仮想NIC名] master [仮想スイッチ名]`
6. ブリッジと仮想NICのup
7. IPアドレスの付与

## `docker-compose`の場合
- `docker-compose`で起動されたコンテナはデフォルトのブリッジネットワークを使用せず
  `docker-compose`プロジェクト単位で専用のブリッジネットワークを持つ
  - デフォルトのブリッジネットワークとはIPアドレスのレンジが異なるため、通信を行うことができない
