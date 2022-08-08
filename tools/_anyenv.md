# anyenv
- `**env`系環境管理ライブラリのラッパー
  - 対象の`**env`ライブラリをanyenv経由でまとめて管理することが可能になる

```
# anyenvのインストール
$ brew install anyenv
$ echo 'eval "$(anyenv init -)"' >> ~/.zshrc
$ exec $SHELL -l

# ライブラリのインストール
$ anyenv install nodeenv # 任意のライブラリ
$ exec $SHELL -l
```

### `anyenv-update`

```
# ライブラリを一括でアップデートするanyenv-updateプラグインのインストール
$ mkdir -p $(anyenv root)/plugins
$ git clone https://github.com/znz/anyenv-update.git
$(anyenv root)/plugins/anyenv-update

# アップデート
$ anyenv update
```


## 参照
- [anyenv](https://github.com/anyenv/anyenv)
