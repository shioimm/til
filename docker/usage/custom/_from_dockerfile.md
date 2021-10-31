# Dockerfileからカスタムイメージを作る
- イメージに含めたいファイルとDockerfileを同じディレクトリに置き、`$ docker build`する
  - イメージに含めないファイルは当該ディレクトリに置かない
    - あるいは`.dockerigrore`で指定する

#### 用途
- イメージの配布

## Dockerfile

```
FROM debian
EXPOSE 80
RUN apt update \
&& apt install -y apache2 php libapache2-mod-php \
&& apt clean \
&& rm -rf /var/lib/apt/lists/* \
&& rm /var/www/html/index.html
COPY index.php /var/www/html
CMD /usr/sbin/apachectl -DFOREGROUND
STOPSIGNAL SIGWINCH
```

```
$ cat index.php
<html>
  <body>
    Your IP <?php echo$_SERVER['REMOTE_ADDR']?>
  </body>
</html>
```

## Dockerfileからイメージをビルド
1. Dockerfileを置いたディレクトリでイメージをビルド
2. イメージ一覧を表示
3. 作成したイメージでコンテナを起動

```
$ docker build . -t myphpimage
$ docker image ls
$ docker run -dit --name myphp -p 8080:80 myphpimage
```

- キャッシュを利用せずにイメージを生成
```
$ docker build . -t myphpimage --no-cache
```

1. イメージをファイルとして保存
2. ファイルサイズを確認
3. 内容を確認
4. ファイルからイメージを読み込み
5. イメージ一覧を確認
```
$ docker save -o saved.tar myphpimage
$ ls -la saved.tar
$ tar tvf saved.tar
$ docker load -i saved.tar
$ docker image ls
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
