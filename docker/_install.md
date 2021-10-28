# 環境構築
## UbuntuにDocker提供パッケージをインストールする
1. Ubuntuのパッケージをアップデート
2. DockerEngineの実行に必要なパッケージをインストール
3. DockerのオフィシャルGPGキー (ファイルが改竄されていないことを確認するために使用する鍵) を追加
4. Dockerダウンロードサイトをaptリポジトリに追加
5. Ubuntuのパッケージをアップデート
6. DockerEngine一式をインストール
7. 一般ユーザーにDockerの利用権限を付与する
8. バージョン確認

```
$ sudo apt update
$ sudo apt -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository \
> "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
> $(lsb_release -cs) \
> stable"
$ sudo apt update
$ sudo apt install -y docker-ce docker-ce-cli containerd.io
$ sudo gpasswd -a ubuntu docker # リモートホストの場合はここで一旦exitしてsshで再接続する
$ docker --version
```

### 参照
- さわって学ぶクラウドインフラ　docker基礎からのコンテナ構築
