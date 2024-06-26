# モジュール
## 種類
- 静的モジュール
- 動的モジュール
  - 設定ファイルに`load_module`ディレクティブで読み込む

### モジュールのカテゴリ
- `core` - プロセスの制御や設定ファイルやエラーログに関するモジュール
- `event` - イベント処理に関するモジュール
- `http` - httpに関するモジュール
- `mail` - mailに関するモジュール

### サードパーティモジュールの組み込み
```
1. モジュールのソースコードを取得
2. nginx本体のソースコードを展開
3. コンパイルオプションを利用してnginx本体と一緒にコンパイルし直す
   静的モジュール / 動的モジュール
```

### インストールフラグ
- `--with-xxx-module`    - 有効化
- `--without-xxx-module` - 無効化

## rewrite
- URLの書き換えを行う

### 1. 条件判定
- ホスト名・パス名・ファイルやディレクトリの有無など条件に合うURLを書き換える
  - ホスト名・ポート番号による判定
    - `server`コンテキスト / `listen` `server_name`ディレクティブ
  - パス名による判定
    - `server`コンテキスト / `location`ディレクティブ
  - ファイルやディレクトリの有無による判定
    - `location`コンテキスト / `try_files`ディレクティブ
  - 条件式による判定
    - `server` or `location`コンテキスト / `if`ディレクティブ
  - クライアントのIPアドレスによる判定
    - `http`コンテキスト` / `geo`ディレクティブ
  - 文字列マッチングによる判定
    - `http`コンテキスト` / `map`ディレクティブ

### 2. URLの書き換え
- URLの文字列を書き換え、変更後のURLにアクセスされたかのように振る舞う
  - `return`ディレクティブによるリダイレクト
    - ステータスコードとリダイレクト先を指定する
  - `rewrite`ディレクティイブによる書き換え
    - 書き換え先は同一のnginxがコンテンツを提供するパス名であること
    - 書き換え元文字列・書き換え先文字列・フラグを指定する

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
