# Rack::Lock
- 引用: [rack/lib/rack/lock.rb](https://github.com/rack/rack/blob/master/lib/rack/lock.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- mutexによってリクエストをシリアライズするミドルウェア
- すべてのリクエストをmutex内でロックする

## `Rack::Lock#call`
```ruby
    def call(env)
      @mutex.lock
      @env = env
      @old_rack_multithread = env[RACK_MULTITHREAD]
      begin
        response = @app.call(env.merge!(RACK_MULTITHREAD => false))
        returned = response << BodyProxy.new(response.pop) { unlock }
      ensure
        unlock unless returned
      end
    end
```
