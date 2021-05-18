# http-2
## 構成

```
lib
├── http
|   ├── 2
|   │   ├── buffer.rb
|   │   ├── client.rb
|   │   ├── compressor.rb            # ヘッダ圧縮(HPACK)フォーマット
|   │   ├── connection.rb
|   │   ├── emitter.rb
|   │   ├── error.rb                 # ストリーム、コネクション、コンプレッサーの例外処理
|   │   ├── flow_buffer.rb
|   │   ├── framer.rb                # バイナリフレームのエンコーディング、デコーディング、バリデーション
|   │   ├── huffman.rb               # HPACK用のハフマンエンコーディング
|   │   ├── huffman_statemachine.rb  # ハフマンデコーダのステートマシン $ rake generate_huffman_tableで生成する
|   │   ├── server.rb
|   │   ├── stream.rb
|   │   └── version.rb
|   └── 2.rb
└── tasks
    └── generate_huffman_table.rb
```

## サンプル構成

```
example
├── Gemfile
├── Gemfile.lock
├── README.md
├── client.rb
├── helper.rb
├── keys
│   ├── server.crt
│   └── server.key
├── server.rb
├── upgrade_client.rb
└── upgrade_server.rb
```

```
$ cd example
$ bundle exec ruby -I../lib server.rb
$ bundle exec ruby -I../lib client.rb
```

## 参照
- [igrigorik/http-2](https://github.com/igrigorik/http-2)
- [HTTP/2 for Ruby](https://lepidum.co.jp/blog/2014-12-22/http2-ruby/)
