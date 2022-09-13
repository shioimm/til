# Hijacking (Rack1.5 ~)
- アプリケーションがクライアントソケットを制御し、任意の操作を行うための機能
  - e.g. WebSocketの実装、クライアントへのデータのストリーミング

## API

```ruby
# full hijackingで使用
env['rack.hijack']

# partial hijackingで使用
env['rack.hijack?']
```

## full hijacking API
- ソケットを通過する内容をアプリケーションによって完全に制御する
- HTTP/1.xによる通信を完全にハイジャックするために使用される
- HTTPヘッダが書き込まれる前に発生する
- アプリケーションによって生成されたレスポンスは無視される
- `env['rack.hijack']`はcallableであり、HTTP/1.xのセマンティックとフォーマットを使用して
  接続に対して読み書きできるIOオブジェクトであることが必要


## partial hijacking API
- アプリケーションがレスポンスボディのストリームを制御する
  - e.g. 双方向ストリーミング

#### ~ 3.0

```ruby
def call(env)
  stream_callback = proc do |stream|
    stream.read(...)
    stream.write(...)
  ensure
    stream.close(...)
  end

  # 'rack.hijack'ヘッダにcallableなオブジェクトを置き、ボディを無視する
  return [200, {'rack.hijack' => stream_callback}, []]
end
```

#### 3.0 ~

```ruby
def call(env)
  stream_callback = proc do |stream|
    stream.read(...)
    stream.write(...)
  ensure
    stream.close(...)
  end

  # ボディをStreaming Bodyに置き換える
  return [200, {}, stream_callback]
end
```

## 参照
- [The new Rack socket hijacking API](https://old.blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/)
- [Hijacking¶ ↑](https://github.com/rack/rack/blob/3012643ea6a89fefe8cc0c68d4992531c367c906/SPEC.rdoc)
- [Response bodies can be used for bi-directional streaming](https://github.com/rack/rack/blob/main/UPGRADE-GUIDE.md#response-bodies-can-be-used-for-bi-directional-streaming)
