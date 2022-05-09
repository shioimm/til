# ログドレイン
- Herokuアプリケーションから収集したログを外部のログサービスに転送するための仕組み

```
# ログドレイン一覧 (addonに値が入っている場合はHerokuAddonsから追加されたもの)
$ heroku drains --json --app <AppName>

# Syslogドレインの追加 (外部のログサービスのURLをshitei)
$ heroku drains:add syslog+tls://logs.example.com:12345 -a <AppName>

# Syslogドレインの削除 (対象のURLを指定)
$ heroku drains:remove syslog+tls://logs.example.com:12345 -a <AppName>
```

## 参照
- [Log Drains](https://devcenter.heroku.com/articles/log-drains)
