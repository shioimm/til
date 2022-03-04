# リダイレクション
```
$ xxx < file
# xxxの標準入力をfileに切替える

$ xxx << word
# xxxの次にwordが行の先頭に出てくるまでの文字列を標準入力として使用する

$ xxx > file
# xxxの標準出力をfileに切替える
# fileが存在していた場合、古い内容は上書きされる

$ xxx >> file
# xxxの標準出力をfileに切替える
# xxxの出力データはファイルの内容に追加される。

$ xxx >& file
# xxxの標準エラー出力をfileに切替える
# fileが存在していた場合、古い内容は上書きされる

$ xxx >>& file
# xxxの標準エラー出力をfileに切替える
# 出力データはファイルの内容に追加される
```

## 引用
- [リダイレクションの種類](http://www.not-enough.org/abe/manual/comm/redirection.html)
