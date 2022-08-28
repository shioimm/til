# timestamp
```ruby
t.datetime :x_date, default: -> { 'NOW()' }
```

- `CURRENT_TIMESTAMP`を使用することができる
- アプリケーションと別にDBのタイムゾーンの設定が必要

```console
ALTER DATABASE "DB_NAME" SET timezone TO 'Asia/Tokyo';
```
