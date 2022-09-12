# Hijacking (Rack1.5 ~)
- アプリケーションがクライアントソケットを制御し、任意の操作を行うための機能
  - e.g. WebSocketの実装、クライアントへのデータのストリーミング

## full hijacking API
- ソケットを通過する内容をアプリケーションによって完全に制御する
- HTTP/1.xによる通信を完全にハイジャックするために使用される
- HTTPヘッダが書き込まれる前に発生する
- アプリケーションによって生成されたレスポンスは無視される

#### API (~ 3.0)
- HTTPヘッダを出力する
- ハイジャックの対象となるソケットが不要になった際にクローズする

```ruby
# full hijackingの実行
env['rack.hijack'].call

# ハイジャックの対象となるソケットオブジェクトへのアクセス
io = env['rack.hijack_io']
io.write("Status: 200\r\n")
io.write("Connection: close\r\n") # HTTP keep-aliveを実装しない場合必要
# ...
io.close
```

#### API (3.0 ~)

```ruby
# full hijackingを実行するために使用されるオブジェクト
# callableであり、HTTP/1.xのセマンティックとフォーマットを使用した接続に対して読み書きできるIOオブジェクト
env['rack.hijack']

# full hijackingの実行
env['rack.hijack'].call
```

## partial hijacking API
- アプリケーションがレスポンスボディのストリームを制御する
  - e.g. 双方向ストリーミング

#### API (3.0 ~)

```ruby
# 真である場合、サーバーがpartial hijackingをサポートしていることを示す
env['rack.hijack?']

# env['rack.hijack?']がtrulyであればresponse_headersを設定可能
response_headers = {}
response_headers["rack.hijack"] = lambda do |io|
  io.write(...)
  # ...
  io.close
end

[200, response_headers, nil]
```

## 参照
- [The new Rack socket hijacking API](https://old.blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/)
- [Hijacking¶ ↑](https://github.com/rack/rack/blob/3012643ea6a89fefe8cc0c68d4992531c367c906/SPEC.rdoc)
