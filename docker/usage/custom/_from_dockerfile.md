# Dockerfileからカスタムイメージを作る
- イメージに含めたいファイルとDockerfileを同じディレクトリに置き、`$ docker build`する
  - イメージに含めないファイルは当該ディレクトリに置かない、あるいは`.dockerigrore`で指定する

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
    && rm /var/www/html/index.html # index.htmlとindex.phpを同じディレクトリに置くとindex.htmlが優先されてしまうため
COPY index.php /var/www/html
CMD /usr/sbin/apachectl -DFOREGROUND
STOPSIGNAL SIGWINCH # httpdを終了させるシグナル (SIGWINCH) を送出するため
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

# 前回のキャッシュを使わない場合
$ docker build . -t myphpimage --nocache

$ docker image ls
$ docker run -dit --name myphp -p 8080:80 myphpimage
```

## キャッシュを利用せずにDockerfileからイメージをビルド
```
$ docker build . -t myphpimage --no-cache
```

## イメージをファイル化 & ファイルからイメージを読み込み
1. イメージを.tarファイルとして保存
2. ファイルサイズを確認
3. 内容を確認
4. .tarファイルからイメージを読み込み
5. イメージ一覧を確認

```
$ docker save -o saved.tar myphpimage
$ ls -la saved.tar
$ tar tvf saved.tar
$ docker load -i saved.tar
$ docker image ls
```

## イメージをDockerHubに登録・ダウンロード
1. Dockerイメージ名を変更 `Dockerイメージ名` -> `<Docker ID>/<リポジトリ名>`
2. DockerHubにログイン
3. push
4. pull
5. DockerHubからログアウト

```
$ docker tag myexample myexampleid/myexample
$ docker login
$ docker push myexampleid/myexample
$ docker pull myexampleid/myexample
$ docker logout
```

## Dockerfile書式
#### ADD / COPY
- イメージにディレクトリやファイルを追加する
  - ADDは圧縮ファイルを自動的に展開する
  - COPYは圧縮ファイルを自動的に展開しない

#### ENTRYPOINT / CMD
- コンテナ起動時 (`$ docker run`) にコンテナ内で実行する規定のコマンドを指定
  - コマンドが終了するとコンテナも終了する
  - ENTRYPOINTはコマンドの指定を強要する
  - CMDは`$ docker run`の際に指定する最後のコマンドのデフォルト値を変更する
  - ENTRYPOINTもCMDも指定しない場合はベースイメージの設定値が引き継がれる

#### ENV
- 環境変数の指定

#### EXPOSE
- コンテナがリッスンするポート番号の指定
- 指定したポートは公開されない (ドキュメントとして機能する)
- 公開するポート番号として別途-pオプションで指定する必要がある

#### FROM
- ベースイメージ

#### ONBUILD
- イメージのビルド完了後に実行する命令

```
ONBUILD COPY ...
```

#### RUN
- イメージ作成時 (`$ docker build`) にコマンドを実行
  - パッケージのインストールやファイルのコピー、変更など
  - 複数のコマンドを実行する際も一つのRUNコマンドで済ませるようにする

#### VOLUME
- ボリュームの指定 (-vオプションに渡すデフォルト値を指定する)

#### WORKDIR
- RUN、CMD、ENTRYPOINT、ADD、COPYの作業ディレクトリを指定

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
