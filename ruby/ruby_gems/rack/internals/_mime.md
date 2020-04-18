# Rack::Mime
- 引用: [rack/lib/rack/mime.rb](https://github.com/rack/rack/blob/master/lib/rack/mime.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- ファイル拡張子に基づいて Content-Type を決定するヘルパー
- 見つかった場合はMIMEタイプを示す文字列を返す
- それ以外の場合は+fallback+(= 'application/octet-stream')を利用する

### USAGE
```ruby
Rack::Mime.mime_type('.foo')

# => "application/foo"
```

## `Rack::Mime#mime_type`
```ruby
    def mime_type(ext, fallback = 'application/octet-stream')
      MIME_TYPES.fetch(ext.to_s.downcase, fallback)
    end
```
