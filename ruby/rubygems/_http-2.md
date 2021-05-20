# http-2
## 構成

```
lib
├── http
|   ├── 2
|   │   ├── buffer.rb                # 文字列からバイナリへのエンコード・バイナリの操作
|   │   ├── client.rb                # クライアント: Connectionのサブクラス
|   │   ├── compressor.rb            # ヘッダ圧縮(HPACK)フォーマット
|   │   ├── connection.rb            # HTTP 2.0のエンコード/デコード、ストリームの状態管理、ヘッダ圧縮機能
|   │   ├── emitter.rb               # イベントエミッタ: 永続的 or 1回限りのイベントコールバックをサポート
|   │   ├── error.rb                 # ストリーム、コネクション、コンプレッサーの例外処理
|   │   ├── flow_buffer.rb           # フローコントロールウィンドウに基づくフレームの分割やバッファリング
|   │   ├── framer.rb                # バイナリフレームのエンコード/デコード、バリデーション
|   │   ├── huffman.rb               # HPACK用のハフマンエンコーディング
|   │   ├── huffman_statemachine.rb  # ハフマンデコーダのステートマシン $ rake generate_huffman_tableで生成
|   │   ├── server.rb                # サーバー: Connectionのサブクラス
|   │   ├── stream.rb                # ストリームの並行多重化、状態遷移、フロー制御、エラー管理のカプセル化
|   │   └── version.rb
|   └── 2.rb
└── tasks
    └── generate_huffman_table.rb
```

## サンプルコード構成

```
example
├── Gemfile           # gem 'http_parser.rb'
├── Gemfile.lock
├── README.md
├── client.rb         # クライアント: ALPN extension HTTP/2
├── helper.rb         # ログ出力用ヘルパー
├── keys
│   ├── server.crt    # TLS接続のための証明書
│   └── server.key    # TLS接続のための秘密鍵
├── server.rb         # サーバー: ALPN extension HTTP/2
├── upgrade_client.rb # クライアント: HTTP/1.1 -> HTTP/2アップグレード
└── upgrade_server.rb # サーバー: HTTP/1.1 -> HTTP/2アップグレード
```

```
$ cd example
$ bundle exec ruby -I../lib server.rb
$ bundle exec ruby -I../lib client.rb
```

## 参照
- [igrigorik/http-2](https://github.com/igrigorik/http-2)
- [HTTP/2 for Ruby](https://lepidum.co.jp/blog/2014-12-22/http2-ruby/)
