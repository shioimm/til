# 設定
### RedHat系OS
#### `/etc/httpd`以下

| ファイル名     | 説明                                                               |
| -              | -                                                                  |
| conf           | 起動時に最初に読み込まれる設定ファイル`http.cong`を含むファイル群  |
| conf.d         | 追加の設定ファイル群                                               |
| conf.modules.d | モジュール関連の設定ファイル群                                     |
| logs           | `/var/log/httpd`へのシンボリックリンク                             |
| modules        | `/usr/lib64/httpd/modules`へのシンボリックリンク                   |
| run            | `run/httpd`へのシンボリックリンク                                  |

### Debian系OS
#### `/etc/apache2/`以下

| ファイル名       | 説明                                                                 |
| -                | -                                                                    |
| apache2.conf     | 起動時に最初に読み込まれる設定ファイル                               |
| conf-available/  | 利用可能な一般的な設定ファイルを配置(文字コードやセキュリティなど)   |
| conf-enabled/    | 現在有効な`conf-available/`内の各設定ファイルへのシンボリックリンク  |
| mods-available/  | 利用可能なモジュールに関するロード設定・基本的な設定ファイルを配置   |
| mods-enabled/    | 現在有効な`mods-available/`内の各設定ファイルへのシンボリックリンク  |
| sites-available/ | 利用可能なWebサイト設定に関するファイルを配置                        |
| sites-enabled/   | 現在有効な`/sites-available`内の各設定ファイルへのシンボリックリンク |
| ports.conf       | どのIP/ポートで待ち受けるかに関する設定ファイル                      |
| envvars          | 他の設定ファイル内部腕使われる環境変数を指定するファイル             |
| magic            | MimeTypeについての情報を指定するファイル                             |

#### `/usr/lib/apache2/`

| ファイル名 | 説明                     |
| -          | -                        |
| modules    | モジュール本体を配置する |

#### `/var/log`

| ファイル名 | 説明           |
| -          | -              |
| apache2    | ログを配置する |

## 設定ファイルの書き方
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

| 項目名            | 説明                                                                  |
| -                 | -                                                                     |
| ServerRoot        | 設定ファイルを置く場所                                                |
| Listen            | 受信するポート番号                                                    |
| User              | 実行ユーザー                                                          |
| Group             | 実行グループ                                                          |
| Include           | 設定ファイルの読み込み                                                |
| Include Optional  | 追加の設定ファイルの読み込み                                          |
| ServerAdmin       | 管理者の連絡先                                                        |
| ServerName        | サーバー自身のホスト名とポート(デフォルトでは自動判別)                |
| ServerSignature   | サーバーが生成するドキュメントのフッター(セキュリティのためoffにする) |
| AllowOverride     | 上書き可否                                                            |
| Required          | アクセス権                                                            |
| DirectoryIndex    | パスを指定せずにアクセスした場合に表示するデフォルトファイル          |
| AddDefaultCharset | デフォルトの文字コード設定                                            |
| DocumentRoot      | ドキュメントルート                                                    |
| Options           | オプション                                                            |
| ScriptAlias       | CGIを実行可能な場所を定義する                                         |
| ErrorLog          | エラーログの置き場所                                                  |
| LogLevel          | ログを出力するレベル                                                  |
| ErrorDocument     | エラーページのカスタマイズ設定                                        |

#### ssl.conf

| 項目名                   | 説明                                        |
| -                        | -                                           |
| SSLCertificateKeyFile    | `/path/to/PEM形式のサーバー秘密鍵ファイル/` |
| SSLCertificateChainFile  | `/path/to/PEM形式のチェーン証明書ファイル/` |
| SSLCertificateFile       | `/path/to/Webサーバー証明書/`               |

## 参照
- [Apache HTTP サーバ バージョン 2.4 ドキュメント](https://httpd.apache.org/docs/2.4/ja/)
- [Apache HTTP Server](https://ja.wikipedia.org/wiki/Apache_HTTP_Server)
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
