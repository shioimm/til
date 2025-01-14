# `/etc/group`

```
$ cat /etc/group
dev:x:1000:user2,user3
...
```

- `グループ名:パスワード:グループID:グループメンバー`
  - パスワードはシャドウパスワードになっている (`/etc/shadow`に設定されている)
