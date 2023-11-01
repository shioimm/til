# Could not get lock /var/lib/dpkg/lock
- `$ sudo apt install`時に発生

```
E: Could not get lock /var/lib/dpkg/lock - open (11 Resource temporarily unavailable)
E: Unable to lock the administration directory (/var/lib/dpkg/) is another process using it?
```

```
$ sudo lsof /var/lib/dpkg/lock-frontend
$ ps aux | grep [a]pt
```
- バックグラウンドで他のプロセスが`lock-frontend`を開いている
  - プロセスが終了するまで待つ
  - プロセスをkillすることもできるが動作の保証はない

## 参照
- [Troubleshooting apt-get or aptitude or Synaptic package manager errors](https://help.ubuntu.com/community/Troubleshooting#Software_Management)
- [How To Fix `Could not get lock /var/lib/dpkg/lock - open (11 Resource temporarily unavailable)` Errors](https://www.linuxuprising.com/2018/07/how-to-fix-could-not-get-lock.html)
- [Unable to lock the administration directory (/var/lib/dpkg/) is another process using it?](https://askubuntu.com/questions/15433/unable-to-lock-the-administration-directory-var-lib-dpkg-is-another-process)
