# 設定
### RedHat系OS
#### `/etc/httpd`以下

| ファイル名     | 説明                                                               |
| -              | -                                                                  |
| conf           | 起動時に最初に読み込まれる設定ファイル`http.conf`を含むファイル群  |
| conf.d         | 追加の設定ファイル群                                               |
| conf.modules.d | モジュール関連の設定ファイル群                                     |
| logs           | `/var/log/httpd`へのシンボリックリンク                             |
| modules        | `/usr/lib64/httpd/modules`へのシンボリックリンク                   |
| run            | `run/httpd`へのシンボリックリンク                                  |

### Debian系OS
#### `/etc/apache2/`以下

| ファイル名       | 説明                                                                                    |
| -                | -                                                                                       |
| apache2.conf     | 起動時に最初に読み込まれるメインの設定ファイル                                          |
| conf-available/  | 一般的な外部設定ファイルを格納 (e.g. 文字コード、セキュリティ)                          |
| conf-enabled/    | 一般的な外部設定ファイルの有効化 (`conf-available/への`シンボリックリンクを格納)        |
| mods-available/  | 拡張モジュール関連設定ファイルを格納                                                    |
| mods-enabled/    | 拡張モジュール関連設定ファイルを有効化 (mods-available/へのシンボリックリンクを格納     |
| sites-available/ | バーチャルホスト関連設定ファイルを格納                                                  |
| sites-enabled/   | バーチャルホスト関連設定ファイルを有効化 (sites-available/へのシンボリックリンクを格納) |
| ports.conf       | ポート番号用の設定ファイル                                                              |
| envvars          | apache2ctlコマンドの環境変数用の設定ファイル                                            |
| magic            | `mod_mime_magic`モジュール用の設定ファイル                                              |

#### `/usr/lib/apache2/`

| ファイル名 | 説明                     |
| -          | -                        |
| modules    | モジュール本体を配置する |

#### `/var/log`

| ファイル名 | 説明           |
| -          | -              |
| apache2    | ログを配置する |

## 参照
- [Apache HTTP サーバ バージョン 2.4 ドキュメント](https://httpd.apache.org/docs/2.4/ja/)
- [Apache HTTP Server](https://ja.wikipedia.org/wiki/Apache_HTTP_Server)
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
- Linuxブートキャンプ
