# Apache
- 参照: [Apache HTTP サーバ バージョン 2.4 ドキュメント](https://httpd.apache.org/docs/2.4/ja/)
- 参照: [Apache HTTP Server](https://ja.wikipedia.org/wiki/Apache_HTTP_Server)

## TL;DR
- オープンソースのクロスプラットフォームWebサーバーソフトウェア
- 核となるCoreに対してモジュールを追加することにより機能を拡張する(`mod_XXX`)
- MPM(マルチプロセッシングモジュール)により多種多様なプラットホームで動作する設計となっている

## モジュールの追加
- モジュールは静的リンクまたは動的リンクにより追加する

### 静的リンク
- Apacheの実行ファイルそのものにモジュールを組み込む
- 高速にモジュール機能を呼び出すことができる
- モジュールの付け外しのために再コンパイルが必要

### 動的リンク
- モジュールを別ファイルとして作成し、必要に応じてモジュールのファイルから機能を呼び出す
  - `mod_so`モジュールを静的リンクしておく必要がある
- オーバーヘッドがかかる
- 再起動のみでモジュールを付け外しできる

## MPM
- サーバーの基本機能として設計されたモジュール
- 最適なサーバーアーキテクチャを選択することができる

### Unix系OSにおけるMPM
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

## 設定ファイル
### RedHat系OS - `/etc/httpd`以下
- `conf`           - 主となる設定ファイル`http.cong`を含むファイル群
- `conf.d`         - 追加の設定ファイル群
- `conf.modules.d` - モジュール関連の設定ファイル群
- `logs`           - `/var/log/httpd`へのシンボリックリンク
- `modules`        - `/usr/lib64/httpd/modules`へのシンボリックリンク
- `run`            - `run/httpd`へのシンボリックリンク

### Debian系OS - `/etc/apache2/`以下
- `apache2.conf`    - 主となる設定ファイル
- `conf-available`  - 文字コードやセキュリティに関する設定ファイル群
- `conf-enabled`    - `conf-available/`内の各設定ファイルへのシンボリックリンク(有効化)
- `mods-available`  - モジュール関連の設定ファイル群
- `mods-enabled`    - `mods-available/`内の各設定ファイルへのシンボリックリンク(有効化)
- `sites-available` - サイト公開に関する設定ファイル群
- `sites-enabled`   - `/sites-available`内の各設定ファイルへのシンボリックリンク(有効化)
- `ports.conf`      - ポートに関する設定ファイル
- `envvars`         - 環境変数
- `magic`

### 設定ファイルの書き方
```
# 設定名 設定値

DocumentRoot "/var/www/html"
```

```
# ディレクティブ(設定範囲の指定)
#   <設定範囲 対象>
#     設定名 設定値
#   </設定範囲>

<Directory "/var/www/html">
  AllowOverride None
</Directory>

# Directory ディレクトリ
# IfModule  モジュール
# Files     ファイル
```

### 設定項目
- `ServerRoot`        - 設定ファイルを置く場所
- `Listen`            - 受信するポート番号
- `User`              - 実行ユーザー
- `Group`             - 実行グループ
- `Include`           - 設定ファイルの読み込み
- `Include Optional   - 追加の設定ファイルの読み込み
- `ServerAdmin`       - 管理者の連絡先
- `ServerName`        - サーバー名(デフォルトでは自動判別)
- `AllowOverride`     - 上書き可否
- `Required`          - アクセス権
- `DirectoryIndex`    - パスを指定せずにアクセスした場合に表示するデフォルトファイル
- `AddDefaultCharset` - デフォルトの文字コード設定
- `DocumentRoot`      - ドキュメントルート
- `Options`           - オプション
- `ScriptAlias`       - CGIを実行可能な場所を定義する
- `ErrorLog`          - エラーログの置き場所
- `LogLevel`          - ログを出力するレベル
- `ErrorDocument`     - エラーページのカスタマイズ設定
