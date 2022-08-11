# ネットワーキング
- Dockerは仮想的なネットワークを作り、Dockerホスト・Dockerコンテナ同士が通信するように構成できる
- ホスト、コンテナにはそれぞれ独自のIPアドレスが割り当てられ、仮想的なネットワークで接続されている

## 種別
### bridgeネットワーク
- 規定のネットワーク (ホストとコンテナがデフォルトで接続される)
- Docker Engineが動作するホスト環境には`docker0`というネットワークインターフェースが作成される
- ホストは`docker0`を通じてbridgeネットワークに接続する
- bridgeネットワークに接続されたコンテナ同士はお互いのIPアドレスで通信可能

#### bridgeネットワークの技術的側面
- bridgeネットワークはIPマスカレードを使って構成されており、
  `-p`オプションを指定することによってIPマスカレードの転送設定を行っている

```
$ docker inspect --format="{{.NetworkSettings.IPAddress}}" web01 # コンテナに割り当てられたIPアドレス
172.17.0.2

$ ifconfig # ホストに割り当てられたIPアドレス
docker0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:26ff:fe4c:9282  prefixlen 64  scopeid 0x20<link>
        ...

$ sudo iptables --list -t nat -n # natテーブルのポート転送設定
```

### hostネットワーク (あまり使われない)
- コンテナがIPマスカレードを使わずにホストのIPアドレスを共有するネットワーク
  (-pオプションを指定できない)
- ホストとコンテナでネットワークが隔離されず、ホストのすべてのポートがコンテナ側に流れる
- コンテナは個別のIPアドレスを持たず、ホストのIPアドレスを共有する
- ホスト上のネットワーク(eth0)のIPアドレスをコンテナ内で利用する
- コンテナ内でプログラムがポートをlistenすると、そのままインターネット側と通信可能になる

### noneネットワーク (あまり使われない)
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

## 参照
- [Docker コンテナ・ネットワークの理解](https://docs.docker.jp/engine/userguide/networking/dockernetworks.html)
- [Docker0 ブリッジのカスタマイズ](https://docs.docker.jp/engine/userguide/networking/default_network/custom-docker0.html)
- [Linuxカーネルのコンテナ機能［5］ ─ネットワーク](https://gihyo.jp/admin/serial/01/linux_containers/0006)
- [Docker Compose入門 (3) ～ネットワークの理解を深める～](https://knowledge.sakura.ad.jp/23899/)
- [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その5:Dockerのネットワークってどうなってるの？ 〜](https://tech-lab.sios.jp/archives/20179)
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
