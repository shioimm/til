# diff

```
# 現在のブランチでステージングされていないファイルの差分を取得
$ git diff

# mainブランチと現在のブランチの間の差分を取得
$ git diff main --

# リモートのmainブランチと現在のブランチの間の差分を取得
$ git diff origin/main --

# ファイル同士を比較
git diff --no-index < -表示するファイル > < +表示するファイル >
```
