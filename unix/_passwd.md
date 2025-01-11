# `/etc/passwd`

```
$ cat /etc/passwd
root:x:0:0:System Administrator:/var/root:/bin/sh
...
```

- `ユーザ名:パスワード:ユーザID:グループID:コメント:ホームディレクトリ:ログインシェル`
  - パスワードはシャドウパスワードになっている (`/etc/shadow`に設定されている)
