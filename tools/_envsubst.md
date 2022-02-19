# `envsubst`
- テンプレートファイルに環境変数を埋め込む

```
$ brew install gettext # gettextのインストールが必要

$ VAL='This is VAL.' envsubst < /path/to/FILE_NAME
```

```
# FILE_NAME

This is a template file.
${VAL} # => This is VAL
```

## 参照
- [GNU gettext utilities: envsubst Invocation - GNU.org](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html)
