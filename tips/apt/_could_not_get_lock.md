# Could not get lock /var/lib/dpkg/lock-frontend

```
$ sudo apt install gdb
E: Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)
E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
```

- dpkgステータスデータベース (パッケージマネージャー) が別のプロセスで使用されている

```
$ sudo rm /var/lib/apt/lists/lock
$ sudo rm /var/lib/dpkg/lock
$ sudo rm /var/lib/dpkg/lock-frontend
```
