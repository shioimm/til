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
- リクエスト時にハイジャックを行いリクエストをアプリケーションに渡さず、
  ソケットを通過する内容をアプリケーションによって完全に制御する
- HTTP/1.xによる通信を完全にハイジャックするために使用される
- HTTPヘッダが書き込まれる前に発生する
  - アプリケーションによって生成されたレスポンスは無視される

#### ~ 3.0
- `env['rack.hijack?']`がtrueであること
- `env['rack.hijack'].respond_to?(:call)`がtrueであること
- `env['rack.hijack'].call`がIOオブジェクトを返すこと
- `env['rack.hijack'].call`に`env['rack.hijack_io']`のIOオブジェクトが代入されること
- `env['rack.hijack_io']`がIOライクなAPIをサポートしていること
  - `read`, `write`, `read_nonblock`, `write_nonblock`,
    `flush`, `close`, `close_read`, `close_write`, `closed?`
- HTTPヘッダがある場合はそのヘッダを出力する
- 不要になった際にIOオブジェクトをクローズする

#### 3.0 ~
- `env['rack.hijack'].respond_to?(:call)`がtrueであること
- `env['rack.hijack']`がHTTP/1.xのセマンティックとフォーマットを使用するIOライクなAPIをサポートしていること
  - `read`, `write`, `read_nonblock`, `write_nonblock`,
    `flush`, `close`, `close_read`, `close_write`, `closed?`

## partial hijacking API
- リクエストをアプリケーションに渡し、レスポンス時にハイジャックを行いレスポンスボディのストリームを制御する
  - e.g. 双方向ストリーミング

#### ~ 3.0
- `env['rack.hijack']`ヘッダに`env['rack.hijcak_io']`プロトコルに準拠した引数を受け取り、
  `#call`に応答するオブジェクトを代入する
- 不要になった際にIOオブジェクトをクローズする

```ruby
def call(env)
  stream_callback = proc do |stream|
    stream.read(...)
    stream.write(...)
  ensure
    stream.close(...)
  end

  # 'rack.hijack'ヘッダにcallableなオブジェクトを置き、ボディを無視する
  return [200, { 'rack.hijack' => stream_callback }, []]
end
```

#### 3.0 ~
- `env['rack.hijack?'] == true`

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
- [Hijacking](https://www.rubydoc.info/github/rack/rack/file/SPEC.rdoc#label-Hijacking)
- [Response bodies can be used for bi-directional streaming](https://github.com/rack/rack/blob/main/UPGRADE-GUIDE.md#response-bodies-can-be-used-for-bi-directional-streaming)
- [What is Rack Hijacking API](https://www.slideshare.net/TokyoIncidents/what-is-rack-hijacking-api-69807904)
