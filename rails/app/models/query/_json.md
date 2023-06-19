# JSON列の検索

```ruby
EventLog.where("json->>'type' = ?", 'success')
```
