# Rack::Auth::Digest::MD5
- 引用: [rack/auth/digest/md5.rb](https://github.com/rack/rack/blob/master/lib/rack/auth/digest/md5.rb)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- RFC 2617に基づきMD5アルゴリズムによるHTTPダイジェスト認証を提供する
- 対象のRackアプリケーションと
  与えられたusernameに対する平文のパスワードを検索するブロックによってinitializeする

## `Rack::Auth::Digest::MD5#call`
```ruby
        def call(env)
          auth = Request.new(env)

          unless auth.provided?
            return unauthorized
          end

          if !auth.digest? || !auth.correct_uri? || !valid_qop?(auth)
            return bad_request
          end

          if valid?(auth)
            if auth.nonce.stale?
              return unauthorized(challenge(stale: true))
            else
              env['REMOTE_USER'] = auth.username

              return @app.call(env)
            end
          end

          unauthorized
        end
```
