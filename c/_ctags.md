# ctags
- 参照: [exuberant ctags](https://hp.vector.co.jp/authors/VA025040/ctags/)

## タグファイルの生成
```
$ ctags -R
```

- タグファイルをリモートリポジトリにpushしないように`.gitignore`に`tags`を指定しておく
```
# ~/.gitignore

tags
```
```
# *.gitignoreをグローバルに適用する
# ~/.gitconfig

[core]
  excludesfile = ~/.gitignore
```
