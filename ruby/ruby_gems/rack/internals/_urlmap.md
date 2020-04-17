# Rack::URLMap
- 引用: [rack/lib/rack/urlmap.rb](https://github.com/rack/rack/blob/master/lib/rack/urlmap.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- 同じプロセス内で複数のアプリケーションへのルーティングを行うためのヘルパー
- アプリケーションへのURLやパスをマッピングしたハッシュを受け取り、それに応じてディスパッチする
  - URLが`http://`もしくは`https://`で始まる前はHTTP/1.1をサポートする
- SCRIPT_NAMEとPATH_INFOを変更し、ディスパッチに関連する部分をSCRIPT_NAME、残りの部分をPATH_INFOになるようにする
- 最も長いパスを最初に試すようにディスパッチする

## `Rack::URLMap#call`
```ruby
    def call(env)
      path        = env[PATH_INFO]
      script_name = env[SCRIPT_NAME]
      http_host   = env[HTTP_HOST]
      server_name = env[SERVER_NAME]
      server_port = env[SERVER_PORT]

      is_same_server = casecmp?(http_host, server_name) ||
                       casecmp?(http_host, "#{server_name}:#{server_port}")

      is_host_known = @known_hosts.include? http_host

      @mapping.each do |host, location, match, app|
        unless casecmp?(http_host, host) \
            || casecmp?(server_name, host) \
            || (!host && is_same_server) \
            || (!host && !is_host_known) # If we don't have a matching host, default to the first without a specified host
          next
        end

        next unless m = match.match(path.to_s)

        rest = m[1]
        next unless !rest || rest.empty? || rest[0] == ?/

        env[SCRIPT_NAME] = (script_name + location)
        env[PATH_INFO] = rest

        return app.call(env)
      end

      [404, { CONTENT_TYPE => "text/plain", "X-Cascade" => "pass" }, ["Not Found: #{path}"]]

    ensure
      env[PATH_INFO]   = path
      env[SCRIPT_NAME] = script_name
    end
```
