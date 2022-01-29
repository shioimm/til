# Usage
- `apachectl` / `apache2ctl`(Ubuntu)

```
# Apacheの起動
$ sudo apachectl start

# Apacheの停止
$ sudo apachectl stop

# Apacheの再起動
$ sudo apachectl restart
```

```
# httpd.confの文法チェック
$ apachectl configtest
```

```
# インクルードしているモジュールの確認
$ apachectl -M | grep headers
headers_module (shared)

# モジュール操作
$ sudo a2enmod headers  # headers_moduleを有効にする
$ sudo a2dismod headers # headers_moduleを無効にする
```
