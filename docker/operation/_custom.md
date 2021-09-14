# カスタムイメージ
## 既存のイメージをカスタマイズする
1. 新しいコンテナを起動
2. ローカルのファイルをコンテナ内へコピー
3. コンテナからイメージを生成
4. イメージへの操作ログを表示
```
$ docker run -dit --name webcontent -p 8080:80 httpd:2.4
$ docker cp      /tmp/index.html  webcontent:/usr/local/apache2/htdocs
$ docker commit  webcontent mycustomed_httpd
$ docker history mycustomed_httpd
```

## Dockerfileからイメージを生成する
- イメージに含めたいファイルとDockerfileを同じディレクトリに置き、`$ docker build`する
  - イメージに含めないファイルは当該ディレクトリに置かない
    - あるいは`.dockerigrore`で指定する

```
FROM httpd # ベースとなるイメージ
COPY index.html /usr/local/apache2/htdocs/
```

1. Dockerfileを置いたディレクトリでイメージをビルド
2. イメージ一覧を表示
3. 作成したイメージでコンテナを起動

```
$ docker build -t myimage01 .
$ docker image ls
$ docker run -dit --name webcontent_docker -p 8080:80 myimage01
```

### Dockerfile書式
#### コマンドの実行
- RUN - イメージ作成時にコマンドを実行(イメージ作成時)
  - パッケージのインストールやファイルのコピー、変更など
  - 複数のコマンドを実行する際も一つのRUNコマンドで済ませるようにする
- ENTRYPOINT - コンテナ実行時にコマンドを実行
  - `$ docker run`に渡す最後のコマンド
- CMD - コンテナ実行時にコマンドを実行
  - `$ docker run`に渡す最後のコマンドのデフォルト値を変更する

#### ポート番号・ボリュームの指定
- EXPOSE - 公開するポート番号の指定
- VOLUME - ボリュームの指定

### ベストプラクティス
- [Dockerfile のベストプラクティス](https://docs.docker.jp/engine/articles/dockerfile_best-practice.html)
  - 1コンテナ1プロセス
  - コンテナが利用するポート番号を明確にする
  - 永続化するファイルの置き場所を明確にする
  - 設定は環境変数で渡す
  - ログを標準出力に書き出す
  - デタッチしていないコンテナは実行後終了する

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
