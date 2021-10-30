# docker-compose
- Docker ComposeはDocker Engineの一部ではなくDocker操作の補佐をするPython製のツール
  - Docker Engineとは別にインストールする必要がある
- 複数のコンテナからなる一つのシステムの構築を簡便に行う
- 操作時点でのdocker-compose.ymlの記述に沿って実行される
  - Docker Composeで起動したコンテナがある状況でdocker-compose.ymlを編集すると
    次回操作時に編集後の内容が適用される
  - 設定 - docker-compose.ymlの記述
  - 起動 - `$ docker-compose up` `-d`でデーモン化
  - 終了 - `$ docker-compose stop`


## docker-compose.yml
```yml
version: '3'    # docker-compose.ymlのファイルフォーマットバージョン

services:       # コンテナを管理する単位
   mycontainer: # コンテナ名
     image:     # Dockerイメージ名
     volumes:   # ボリューム定義
     ports:     # ポート番号の設定
```

#### Dockerfileとの併用
- Dockerfileをdocker-compose.yml内でコンテキストとして利用することもできる

```yml
version: '3'

services:
  mycontainer:
    build:
      context: . # カレントディレクトリのDockerfileを利用
```

## 引用・参照
- [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その4:docker-composeってなに？ 〜](https://tech-lab.sios.jp/archives/20051)
