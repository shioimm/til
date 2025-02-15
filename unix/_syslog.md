# syslog

#### Linux系

```
# ログを新しい順に、"1970-01-01"以降のもののみ、リアルタイムに表示
$ journalctl -r --since "1970-01-01" -f

# プロセス名でフィルタリング
$ journalctl -u nginx

# PIDでフィルタリング
$ journalctl _PID=12345
```

#### macOS

```
# ログを新しい順に、"1970-01-01"以降のもののみ、リアルタイムに表示
$ log stream --predicate 'timestamp >= "1970-01-01 00:00:00"'
# (リアルタイム表示しない場合はlog show)

# プロセス名でフィルタリング
$ log show --predicate 'process == "nginx"' --info

# PIDでフィルタリング
$ log show --predicate 'processID == 12345' --info
```
