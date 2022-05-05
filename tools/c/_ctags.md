# ctags
#### 定義元ジャンプ

```
ctrl + ]

# ジャンプ元に戻る
ctrl + t
```

#### tagsファイルの生成

```
$ ctags -R
```

```
# tagsファイルをリモートリポジトリにpushしないように.gitignoreにtagsを指定しておく
# ~/.gitignore ($HOME直下)
tags
```

#### その他

```
# サポートしているプログラミング言語一覧
$ ctags --list-languages

# プログラミング言語ごとの走査の対象となるファイルの拡張子一覧
$ ctags --list-maps
```

## 参照
- [exuberant ctags](https://hp.vector.co.jp/authors/VA025040/ctags/)
