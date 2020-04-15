# Rack::ShowExceptions
- 引用: [rack/lib/rack/show_exceptions.rb](https://github.com/rack/rack/blob/master/lib/rack/show_exceptions.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- Rackがラップしたアプリケーションから発生したすべての例外を捕捉する
- ソースファイルやクリック可能なコンテキスト、Rack環境全体、リクエストデータなど
  有用なバックトレースを表示する

## `Rack::ShowExceptions#call`
```ruby
    def call(env)
      @app.call(env)
    rescue StandardError, LoadError, SyntaxError => e
      exception_string = dump_exception(e)

      env[RACK_ERRORS].puts(exception_string)
      env[RACK_ERRORS].flush

      if accepts_html?(env)
        content_type = "text/html"
        body = pretty(env, e)
      else
        content_type = "text/plain"
        body = exception_string
      end

      [
        500,
        {
          CONTENT_TYPE => content_type,
          CONTENT_LENGTH => body.bytesize.to_s,
        },
        [body],
      ]
    end
```
