# .gitignore
#### .gitignoreをグローバルに適用する

```
# ~/.gitconfig ($HOME直下)

[core]
  excludesfile = ~/.gitignore
```

#### ローカル環境限定で特定のファイルをGit管理下から除外する
- `.git/info/exclude`に対象のファイル名を指定する
  - `.git/info/exclude`に記述したファイルはGit管理下から除外される
  - `.git/info/exclude`自身もGit管理下から除外されている
