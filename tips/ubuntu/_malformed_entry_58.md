# Malformed entry 58 in list file /etc/apt/sources.list (Component)
- aptリポジトリに誤ったサイトを追加した際に発生

```
E: Malformed entry 58 in list file /etc/apt/sources.list (Component)
E: The list of sources could not be read.
```

- `/etc/apt/sources.list`ファイルの行末に誤ったサイトが追加されていることを確認
```
$ cat /etc/apt/sources.list
```
- `$ sudo vim /etc/apt/sources.list`で該当行を削除

- [How do I remove a malformed line from my sources.list?](https://askubuntu.com/questions/78951/how-do-i-remove-a-malformed-line-from-my-sources-list)
