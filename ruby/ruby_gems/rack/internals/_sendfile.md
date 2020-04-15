# Rack::Sendfile
- 引用: [rack/lib/rack/sendfile.rb](https://github.com/rack/rack/blob/master/lib/rack/sendfile.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- ファイルシステムのパスに合わせて最適化されたファイル提供を行うWebサーバーを操作するミドルウェア
- ファイルからボディが提供されているレスポンスに割り込み、サーバー固有のX-Sendfileヘッダに置き換える
  - Webサーバーはファイルの内容をクライアントに書き込む責任がある
  - これによりRubyバックエンドが必要とする作業量を劇的に減らすことができ、
    Webサーバーの最適化されたファイル配信コードを利用することができる

### Rack::Sendfileミドルウェアを利用する条件
- レスポンスボディが+to_path+に対応すること
  - Rack::Filesやその他のコンポーネントは+to_path+を実装している
- リクエストがX-Sendfile-Typeヘッダを含んでいること
  - X-Sendfile-Typeヘッダは通常Webサーバの設定によって付与される

## `Rack::Sendfile#call`
```
    def call(env)
      status, headers, body = @app.call(env)
      if body.respond_to?(:to_path)
        case type = variation(env)
        when 'X-Accel-Redirect'
          path = ::File.expand_path(body.to_path)
          if url = map_accel_path(env, path)
            headers[CONTENT_LENGTH] = '0'
            # '?' must be percent-encoded because it is not query string but a part of path
            headers[type] = ::Rack::Utils.escape_path(url).gsub('?', '%3F')
            obody = body
            body = Rack::BodyProxy.new([]) do
              obody.close if obody.respond_to?(:close)
            end
          else
            env[RACK_ERRORS].puts "X-Accel-Mapping header missing"
          end
        when 'X-Sendfile', 'X-Lighttpd-Send-File'
          path = ::File.expand_path(body.to_path)
          headers[CONTENT_LENGTH] = '0'
          headers[type] = path
          obody = body
          body = Rack::BodyProxy.new([]) do
            obody.close if obody.respond_to?(:close)
          end
        when '', nil
        else
          env[RACK_ERRORS].puts "Unknown x-sendfile variation: '#{type}'.\n"
        end
      end
      [status, headers, body]
    end
```
