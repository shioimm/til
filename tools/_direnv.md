# direnv
- [direnv/direnv](https://github.com/direnv/direnv)
- ディレクトリごとに環境変数を管理する
- `$ direnv edit`で作成される.envrcは必ずignoreする

#### 新しく環境変数を設定する

```
$ direnv edit /path/to
```

```
# .envrc

export XXXX=xxxx
```

```
# 環境変数を許可
$ direnv allow /path/to
```
