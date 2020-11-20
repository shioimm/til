# Hijacking
- 参照: [The new Rack socket hijacking API](https://old.blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## TL;DR
- アプリケーションがクライアントソケットを制御し、任意の操作を行うための機能
- Rack1.5から導入

### Rack環境変数
- `'rack.hijack?'`
  - アプリケーションサーバーがHijacking APIをサポートしているかどうか
- `rack.hijack`
  - `#call`に応答するオブジェクト
  - ハイジャック操作を行う
- `rack.hijack_io`
  - ハイジャックされたソケットオブジェクト

## full hijacking API
- アプリケーションがソケットを完全に制御することができる
  - アプリケーションサーバはソケットを介して何も送信しない
- ソケットを介して任意の(HTTP 以外の)プロトコルを実装したい場合に便利

### アプリケーション実装
- `rack.hijack_io`がすべてのHTTPヘッダを出力するようにする
  - HTTP keep-aliveを自力で実装しない場合: `Connection: close`ヘッダも出力する
- IOオブジェクトが不要になったら`close`する

## partial hijacking API
- アプリケーションサーバーがヘッダを送信した後に
  アプリケーションがソケットを制御することができる
- ストリーミングに便利

### アプリケーション実装
- `rack.hijack`にProcオブジェクトを割り当てる
  - Procオブジェクトはアプリケーションサーバがヘッダを送信した後に呼び出される
  - アプリケーションサーバーはRackレスポンスのボディを無視して
    `rack.hijack`を`#call`し、返り値をクライアントソケットに渡す
- Procオブジェクトが不要になったら`close`する
