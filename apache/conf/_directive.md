# ディレクティブ
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
