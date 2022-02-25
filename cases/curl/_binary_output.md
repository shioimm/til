# Binary output

```
$ curl localhost:12345
Warning: Binary output can mess up your terminal. Use "--output -" to tell
Warning: curl to output it to your terminal anyway, or consider "--output
Warning: <FILE>" to save to a file.
```

- サーバーからバイナリ形式でレスポンスを受け取っている

```
# 別ファイルに書き出す
$ curl localhost:12345 -o outFile

$ file outFile
outFile: data

$ cat outFile
<response data>
```

## 参照
- [curl.1 the man page](https://curl.se/docs/manpage.html)
