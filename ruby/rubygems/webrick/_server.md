# サーバー
- [WEBrick::GenericServer](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aGenericServer.html)
  - サーバーの抽象クラス
- [WEBrick::HTTPServer](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServer.html)
  - HTTPサーバークラス

## WEBrickサーバーの仕組み
1. 構築
    - サーバーインスタンスの生成
    - サーブレットのマウント
    - シグナルハンドラの登録
    - サーバーの開始
2. `listen`
3. リクエストの`accept`
4. サーバーはリクエストパスに応じてマウントしたサーブレットのインスタンスを生成
5. 生成されたサーブレットインスタンスがリクエストを処理しレスポンスを返す
6. `2`に戻る
7. `shutdown`

## サーブレットのマウント
### `HTTPServer#mount`
- `mount(dir, servlet, *options)` -> ()
  - サーバー上のディレクトにサーブレットをマウントする
    - `options` - サーブレットのコンストラクタに渡す引数
