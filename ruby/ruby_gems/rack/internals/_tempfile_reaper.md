# Rack::TempfileReaper
- 引用: [rack/lib/rack/tempfile_reaper.rb](https://github.com/rack/rack/blob/master/lib/rack/tempfile_reaper.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- リクエスト中に作成された一時ファイルを追跡して削除するミドルウェア

## `Rack::TempfileReaper#call`
```
    def call(env)
      env[RACK_TEMPFILES] ||= []
      status, headers, body = @app.call(env)
      body_proxy = BodyProxy.new(body) do
        env[RACK_TEMPFILES].each(&:close!) unless env[RACK_TEMPFILES].nil?
      end
      [status, headers, body_proxy]
    end
```
