# Rack::Static
- 引用: [rack/lib/rack/static.rb](https://github.com/rack/rack/blob/master/lib/rack/static.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- オプションで渡されるURLプレフィックスやルートマッピングに基づき、
  静的ファイル(javascriptファイル、画像、スタイルシートなど) へのリクエストを遮断し、
  Rack::Files オブジェクトを使用して提供するミドルウェア
  - これによりRackスタックは動的ファイルおよび静的ファイルの両方を提供することができる

## `Rack::Static#call`
```ruby
    def call(env)
      path = env[PATH_INFO]

      if can_serve(path)
        if overwrite_file_path(path)
          env[PATH_INFO] = (add_index_root?(path) ? path + @index : @urls[path])
        elsif @gzip && env['HTTP_ACCEPT_ENCODING'] && /\bgzip\b/.match?(env['HTTP_ACCEPT_ENCODING'])
          path = env[PATH_INFO]
          env[PATH_INFO] += '.gz'
          response = @file_server.call(env)
          env[PATH_INFO] = path

          if response[0] == 404
            response = nil
          elsif response[0] == 304
            # Do nothing, leave headers as is
          else
            if mime_type = Mime.mime_type(::File.extname(path), 'text/plain')
              response[1][CONTENT_TYPE] = mime_type
            end
            response[1]['Content-Encoding'] = 'gzip'
          end
        end

        path = env[PATH_INFO]
        response ||= @file_server.call(env)

        if @cascade && response[0] == 404
          return @app.call(env)
        end

        headers = response[1]
        applicable_rules(path).each do |rule, new_headers|
          new_headers.each { |field, content| headers[field] = content }
        end

        response
      else
        @app.call(env)
      end
    end
```
