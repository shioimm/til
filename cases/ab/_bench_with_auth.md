# アクセス時にログインが必要なURIに対するベンチマーク
- EditThisCookieで取得したCookieのセッション値を`-C`オプションに渡す
```
$ ab -n 100 -c 5 -C '_APPNAME_session=...' 'http://localhost:3000/api/v1/...'
```
