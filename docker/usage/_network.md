# ネットワーク
- bridgeネットワークに接続されたDockerホスト・Dockerコンテナ同士はIPアドレスで通信可能
- 任意に作成されたDockerネットワークに接続されたDockerコンテナ同士はコンテナ名で通信可能

## ネットワークの確認

```
$ docker network ls
```

## コンテナに割り当てられたIPアドレスの確認
- コンテナ内でifconfig

```
$ docker exec -it <ContainerName> /bin/bash
> ifconfig
```

- bridgeに接続されている全コンテナのIPアドレスを表示
  - フォーマット書式: `{{ .項目名 }}`

```
$ docker network inspect bridge

# フォーマット
$ docker network inspect --format='{{range $host, $conf := .Containers}}{{$conf.Name}}->{{$conf.IPv4Address}}{{\n}}{{end}}' bridge
```

- 特定のコンテナのIPアドレスを確認

```
$ docker container run -dit --name web01 -p 8080:80 httpd:2.4
$ docker container inspect web01

# フォーマット
$ docker container inspect --format="{{.NetworkSettings.IPAddress}}" web01
```

## コンテナ同士の通信
- 同じホスト上に作成されたコンテナに対してping(1)

```
$ docker exec -it <ContainerName> /bin/bash
> ping ***.***.***.***
```

## 任意のDockerネットワークの作成
- 任意のDockerネットワークを作成し、作成したネットワークにDockerコンテナを参加させる
  - 通信先にコンテナ名を指定して通信することができるようになる
    - 規定のネットワークの場合: 通信時にIPアドレスを指定する必要がある
- Dockerホスト上には作成したDockerネットワークのネットワークインターフェースが追加される
  - ネットワークインターフェース名: `br-DockerネットワークIDの先頭`

```
$ docker network create mydockernet
$ docker network ls # ネットワーク一覧を確認
$ docker network inspect mydockernet # 作成したネットワークのIPアドレス (IPAM > Config > Subnet) を確認
```

## 任意のDockerネットワークに参加するコンテナを作る
1. ネットワークに接続するコンテナを作成
2. コンテナがネットワークに接続していることを確認

```
$ docker run -dit --name web01 -p 8080:80 --net mydockernet httpd:2.4
$ docker container inspect --format="{{.NetworkSettings}}" web01
```

#### コンテナ名で通信できることを確認する

```
$ docker run --rm -it --net mydockernet ubuntu /bin/bash
/# apt install -y iproute2 iputils-ping curl
/# ping -c 4 web01
/# curl http://web01/
```

## ネットワークへの接続・切断
1. コンテナをbridgeネットワークから切断
2. コンテナを任意のDockerネットワークに接続

```
$ docker network disconnect bridge web01
$ docker network connect mydockernet web01
```

## ネットワークを削除
```
$ docker network rm mydockernet
```

## hostネットワークでの接続

```
$ docker run ... --net host
```

## noneネットワークでの接続

```
$ docker run ... --net none
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
