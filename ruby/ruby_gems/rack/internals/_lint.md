# Rack::Lint
- 引用: [rack/lib/rack/lint.rb](https://github.com/rack/rack/blob/master/lib/rack/lint.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- Rack APIへの適合性をチェックするためのミドルウェア
- アプリケーション・リクエスト・レスポンスがRack仕様に準拠しているかどうかを検証する

## `Rack::Lint#call`
```ruby
    ## This specification aims to formalize the Rack protocol.  You
    ## can (and should) use Rack::Lint to enforce it.
    ##
    ## When you develop middleware, be sure to add a Lint before and
    ## after to catch all mistakes.

    ## = Rack applications

    ## A Rack application is a Ruby object (not a class) that
    ## responds to +call+.
    def call(env = nil)
      dup._call(env)
    end

    def _call(env)
      ## It takes exactly one argument, the *environment*
      assert("No env given") { env }
      check_env env

      env[RACK_INPUT] = InputWrapper.new(env[RACK_INPUT])
      env[RACK_ERRORS] = ErrorWrapper.new(env[RACK_ERRORS])

      ## and returns an Array of exactly three values:
      ary = @app.call(env)
      assert("response is not an Array, but #{ary.class}") {
        ary.kind_of? Array
      }
      assert("response array has #{ary.size} elements instead of 3") {
        ary.size == 3
      }

      status, headers, @body = ary
      ## The *status*,
      check_status status
      ## the *headers*,
      check_headers headers

      hijack_proc = check_hijack_response headers, env
      if hijack_proc && headers.is_a?(Hash)
        headers[RACK_HIJACK] = hijack_proc
      end

      ## and the *body*.
      check_content_type status, headers
      check_content_length status, headers
      @head_request = env[REQUEST_METHOD] == HEAD
      [status, headers, self]
    end
```
