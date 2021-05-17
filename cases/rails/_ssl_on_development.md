# 開発環境をSSL化
1. mkcertを利用して自己署名証明書を作成
    - [mkcert](https://github.com/FiloSottile/mkcert)

```
$ mkcert -install
$ mkdir lib/ssl/
$ cd lib/ssl/
$ mkcert localhost
```

2. Pumaを設定
```
# config/puma.rb

if "development" == ENV.fetch("RAILS_ENV") { "development" }
  ssl_bind "0.0.0.0", 4567, {
    cert: Rails.root.join("lib", "ssl", "localhost.pem"),
    key: Rails.root.join("lib", "ssl", "localhost-key.pem")
  }
end

# 3000番ポートを使用する場合は port ENV.fetch("PORT") { 3000 } 行を削除する
```

3. サーバー起動
```
$ rails s # https://localhost:9292
```
