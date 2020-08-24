#nginx
- 参照: [nginx](https://nginx.org/en/)
- 参照: [nginx](https://ja.wikipedia.org/wiki/Nginx)
- 参照: nginx実践ガイド

## TL;DR
- オープンソースのクロスプラットフォームWebサーバーソフトウェア
  - 静的コンテンツの高速な配信に対応し、リバースプロキシの機能を持つ
- 処理性能・高い並行性・メモリ使用量の小ささに焦点を当てて開発されている
- スレッドやプロセスベースではなく非同期のイベント駆動アプローチを用いる

### 用途
- 静的なコンテンツの配信
- 動的なコンテンツの配信
- ロードバランサ / リバースプロキシ

## 内部構造
- nginxではmasterが複数のworkerを動作させ、workerがIOを多重化させることにより処理を高速化している
  - ネットワークIOはデフォルトで多重化されている
  - ファイルIOは設定により多重化が可能になっているが、多重化しない方が性能が高い場合もある

###`master process` - rootで動作
- 設定ファイルの読み込み
- ソケットの待ち受けの設定
  - socket、bind、listen
- workerの起動・監視

### `worker process` - 一般ユーザーで動作
- イベントループ処理
- masterが待ち受けを設定したソケットを使って接続を受け付け
- ネットワークIOの実行
  - accept、recv、send
- ファイルIOの実行
  - worker - アプリケーション間の接続
- HTTPやSSL/TLSのプロトコル処理の実行

## モジュール構造
- nginxはモジュールを追加することにより機能を拡張することができる
  - 静的モジュール
    - 本体に組み込み済みのモジュール
  - 動的モジュール
    - バイナリが別ファイルに収められたモジュール、別途読み込みの設定が必要

## パッケージの種類
- mainline - 最新版(推奨)
- stable   - 安定板

## ディレクトリ構造
### `/etc`
- `/logrotate.d/nginx`
  - ログのローテーションの設定ファイル
- `/nginx`
  - 設定ファイル群
  - `nginx.conf`           - 主となる設定ファイル
  - `mime.types`           - ファイルの拡張子とContent-Typeのマッピングテーブル
  - `/conf.d/default.conf` - 基本的なWebサーバーとしての設定(ポート番号、ドキュメントルートetc)
  - `fastcgi_params`       - FastCGIのパラメータとnginxの変数やテキストのマッピングテーブル
  - `scgi_params`          - SCGIのパラメータとnginxの変数やテキストのマッピングテーブル
  - `uwsgi_params`         - uWSGIのパラメータとnginxの変数やテキストのマッピングテーブル

### `/usr`
- `/lib/systemd/system/nginx.service`
  - systemdの設定ファイル(起動スクリプト)
- `/lib64/nginx/modules`
  - 追加モジュール群
- `/libexec/initscripts/legacy-actions/nginx`
  - systemdで対応できないコマンド群
  - upgrade時に実行されるコマンドが配置される
- `/share/doc/nginx-xxx(ver)`
  - ドキュメント群
- `/share/nginx/html`
  - デフォルトのドキュメントルートとなるディレクトリ

### `/var`
- `/cache/nginx`
  - キャッシュファイル群
- `/log/nginx`
  - ログファイル群
