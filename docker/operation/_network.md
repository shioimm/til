# ネットワーク
1. ネットワークの確認
2. httpdコンテナを2つ立ち上げる
3. httpdコンテナのIPアドレスを確認
4. ネットワークに接続されている全コンテナのIPアドレスを確認
5. ホストのIPアドレスを確認(ネットワークインターフェース: docker0)
6. ホストからIPパケットフィルタルールのnatテーブルを確認
```
$ docker network   ls
$ docker container run -dit --name web01 -p 8080:80 httpd:2.4
$ docker container run -dit --name web02 -p 8081:80 httpd:2.4
$ docker container inspect --format="{{.NetworkSettings.IPAddress}}" web01
$ docker network   inspect bridge
$ ifconfig
$ sudo iptables --list -t nat -n
```

#### bridgeネットワーク
- Dockerホスト(Docker Engine)・Dockerコンテナには独立したIPアドレスが割り当てられる
- Dockerホスト(Docker Engine)・Dockerコンテナにはbridgeネットワークに接続される
- bridgeネットワークはIPマスカレードを使って構成されている

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
