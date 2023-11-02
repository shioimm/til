# `fatal: could not read Username for 'https://github.com': terminal prompts disabled`
- パーソナルアクセストークンを.gitconfigに設定する
  - GitHub > Developer settings > Generate new token
    - `repo`にチェックを入れる

```
$ git config --global url."https://パーソナルアクセストークン:x-oauth-basic@github.com/".insteadOf "https://github.com/"
```

#### 発生状況
- Macのローカルの.vimrcに新しいVimプラグインを追加して`:PlugInstall`を実行(vim-plug)
