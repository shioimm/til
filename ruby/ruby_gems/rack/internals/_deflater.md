# Rack::Deflater
- 引用: [rack/lib/rack/deflater.rb](https://github.com/rack/rack/blob/master/lib/rack/deflater.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- gzipでレスポンスを圧縮するためのミドルウェア
- httpレスポンスのコンテンツエンコーディングを可能にし、通常は圧縮を目的とする
- エンコーディングがサポートされているか許可されているかを自動的に検出する

### 現在サポートされているエンコーディング
- ⭕️ gzip
- ⭕️ identity (no transformation)
- ❌ deflate

## `Rack::Deflater#call`
```ruby
    def call(env)
      status, headers, body = @app.call(env)
      headers = Utils::HeaderHash[headers]

      unless should_deflate?(env, status, headers, body)
        return [status, headers, body]
      end

      request = Request.new(env)

      encoding = Utils.select_best_encoding(%w(gzip identity),
                                            request.accept_encoding)

      # Set the Vary HTTP header.
      vary = headers["Vary"].to_s.split(",").map(&:strip)
      unless vary.include?("*") || vary.include?("Accept-Encoding")
        headers["Vary"] = vary.push("Accept-Encoding").join(",")
      end

      case encoding
      when "gzip"
        headers['Content-Encoding'] = "gzip"
        headers.delete(CONTENT_LENGTH)
        mtime = headers["Last-Modified"]
        mtime = Time.httpdate(mtime).to_i if mtime
        [status, headers, GzipStream.new(body, mtime, @sync)]
      when "identity"
        [status, headers, body]
      when nil
        message = "An acceptable encoding for the requested resource #{request.fullpath} could not be found."
        bp = Rack::BodyProxy.new([message]) { body.close if body.respond_to?(:close) }
        [406, { CONTENT_TYPE => "text/plain", CONTENT_LENGTH => message.length.to_s }, bp]
      end
    end
```
