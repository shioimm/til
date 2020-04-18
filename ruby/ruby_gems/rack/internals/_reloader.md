# Rack::Reloader
- 引用: [rack/lib/rack/reloader.rb](https://github.com/rack/rack/blob/master/lib/rack/reloader.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- ファイルが変更されたとき、ファイルをリロードするためのミドルウェア
- バックグラウンドではファイルをリロードしない
  - アクティブに呼び出された場合のみリロードを実行する
- すべてのリクエストの開始時にチェック/リロードサイクルを実行する
- 本番環境での使用に適しているケースとしては、
  どのファイルも一度だけしかチェックされず、かつシステムコールの`stat(2)`しか呼ばれていない場合

## `Rack::Reloader#call`
```ruby
    def call(env)
      if @cooldown and Time.now > @last + @cooldown
        if Thread.list.size > 1
          @reload_mutex.synchronize{ reload! }
        else
          reload!
        end

        @last = Time.now
      end

      @app.call(env)
    end
```
