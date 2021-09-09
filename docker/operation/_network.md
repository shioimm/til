# ネットワーク
- bridgeネットワークに接続されたDockerホスト・Dockerコンテナ同士はIPアドレスで通信可能
- 任意のネットワークに接続されたDockerコンテナ同士はコンテナ名で通信可能

## 操作
1. 現在のネットワークの確認
2. httpdコンテナを立ち上げる
3. httpdコンテナのIPアドレスを確認
4. ネットワークに接続されている全コンテナのIPアドレスを確認
5. ホストのIPアドレスを確認(規定のネットワークインターフェース名: docker0)
6. ホストからIPパケットフィルタルールのnatテーブルを確認
```
$ docker network   ls
$ docker container run -dit --name web01 -p 8080:80 httpd:2.4
$ docker container inspect --format="{{.NetworkSettings.IPAddress}}" web01
$ docker network   inspect bridge
$ ifconfig
$ sudo iptables --list -t nat -n
```

## 任意のネットワークの作成
- 任意のDockerネットワークを作成し、作成したネットワークにDockerコンテナを参加させる
  - 通信先にコンテナ名を指定して通信することができるようになる
    - 規定のネットワークの場合: 通信時にIPアドレスを指定する必要がある
- Dockerホスト上には作成したDockerネットワークのネットワークインターフェースが追加される
  - ネットワークインターフェース名: `br-DockerネットワークIDの先頭`

### 操作
1. 新しいネットワークを作成
2. 現在のネットワークの確認
3. ネットワークのIPアドレスを確認(`IPAM` > `Config` > `Subnet`)
4. ネットワークに接続するコンテナを作成
5. コンテナがネットワークに接続していることを確認
6. コンテナを停止
7. コンテナを削除
```
$ docker network create  mydockernet
$ docker network ls
$ docker network inspect mydockernet
$ docker run -dit --name web01 -p 8080:80 --net mydockernet httpd:2.4
$ docker container inspect --format="{{.NetworkSettings}}" web01
$ docker container stop web01
$ docker container rm   web01
$ docker network   rm   mydockernet
```

### 既存のコンテナへの操作
1. コンテナをネットワークに接続する
2. コンテナをネットワークから切断する
```
$ docker network connect    mydockernet web01
$ docker network disconnect mydockernet web01
```

## bridgeネットワーク
- DockerホストとDockerコンテナがデフォルトで接続されるネットワーク
- Dockerホスト(Docker Engine)・Dockerコンテナには独立したIPアドレスが割り当てられる
- bridgeネットワークはIPマスカレードを使って構成されている
  (-pオプションを指定する)

## hostネットワーク(あまり使われない)
- DockerコンテナがIPマスカレードを使わずにDockerホストのIPアドレスを共有するネットワーク
  (-pオプションを指定できない)
- DockerホストのすべてのポートがDockerコンテナ側に流れる
- Dockerコンテナは個別のIPアドレスを持たず、DockerホストのIPアドレスを共有する
```
$ docker run ... --net host
```

## noneネットワーク(あまり使われない)
- コンテナをネットワークに接続しない設定
```
$ docker run ... --net none
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
