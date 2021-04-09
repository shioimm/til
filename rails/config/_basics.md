# `Rails.application.configure`

```ruby
Rails.application.configure do
  # /public 以下から静的ファイルを配信するかしないか
  # Produnction
  #   静的ファイルをnginx / Apacheで配信する場合はfalse
  #   Herokuでホストしている場合はtrue(静的ファイルの配信機能がないため・別途CDNが不可欠)
  #   rails_12factorを使っている場合はfalse
  # Produnction以外
  #   true
  config.public_file_server.enabled = false
end
```
