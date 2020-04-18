# Rack::Files
- 引用: [rack/lib/rack/file.rb](https://github.com/rack/rack/blob/master/lib/rack/file.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- 静的ファイルを提供するミドルウェア
- Rackリクエストのパスに応じて、与えられた+root+ディレクトリ以下のファイルを提供する
```
例:
Rack::Files.new("/etc") を使うと
'passwd'ファイルにhttp://localhost:9292/passwd のようにアクセスすることができる
```
- ハンドラはボディがRack::Filesであるかどうかを検出し，+path+上でsendfileのようなメカニズムを利用する


## `Rack::Files#call`
```ruby
    def call(env)
      # HEAD requests drop the response body, including 4xx error messages.
      @head.call env
    end
```
