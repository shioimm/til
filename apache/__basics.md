# Apache HTTP Server
- オープンソースのクロスプラットフォームWebサーバーソフトウェア
- 核となるCoreに対してモジュールを追加することにより機能を拡張する(`mod_XXX`)
- MPM(マルチプロセッシングモジュール)により多種多様なプラットホームで動作する設計となっている

## モジュールの追加
- モジュールは静的リンクまたは動的リンクにより追加する

#### 静的リンク
- Apacheの実行ファイルそのものにモジュールを組み込む
- 高速にモジュール機能を呼び出すことができる
- モジュールの付け外しのために再コンパイルが必要

#### 動的リンク
- モジュールを別ファイルとして作成し、必要に応じてモジュールのファイルから機能を呼び出す
  - `mod_so`モジュールを静的リンクしておく必要がある
- オーバーヘッドがかかる
- 再起動のみでモジュールを付け外しできる

## MPM
- サーバーの基本機能として設計されたモジュール
- 最適なサーバーアーキテクチャを選択することができる

#### Unix系OSにおけるMPM
- prefork型
- worker型
- event型

## ドキュメントルート
- Apacheをインストールした時点でドキュメントルートが作成される
  - デフォルトで`/var/www/html/`
- ドキュメントルートは`/etc`以下の設定ファイルに記述される
  - RedHat系OS - `/etc/httpd/conf/httpd.conf`
  - Debian系OS - `/etc/apache2/apache2.conf`

```
# /etc/httpd/conf/httpd.conf (CentOS)

#
# DocumentRoot: The directory out of which you will serve your
# documents. By default, all requests are taken from this directory, but
# symbolic links and aliases may be used to point to other locations.
#
DocumentRoot "/var/www/html"
```

## 参照
- [Apache HTTP サーバ バージョン 2.4 ドキュメント](https://httpd.apache.org/docs/2.4/ja/)
- [Apache HTTP Server](https://ja.wikipedia.org/wiki/Apache_HTTP_Server)
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
