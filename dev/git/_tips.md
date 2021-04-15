# Tips
### リモートブランチにf pushできない
```sh
$ git push -f origin/dependabot/bundler/xxxx                                                                     ✘ 1
To github.com:Catal/Nozomi.git
 ! [rejected]            dependabot/bundler/xxxx -> dependabot/bundler/xxxx (stale info)
error: failed to push some refs to 'git@github.com:shioimm/til.git'
// ヒントが出ない
```
- 原因: リモート作業ブランチとローカル作業ブランチに差分が発生している
- 解決: `$ git fetch` -> `$ git rebase` -> `$ git push -f`

```sh
$ git fetch
$ git rebase origin/dependabot/bundler/xxxx
$ git push -f origin/dependabot/bundler/xxxx
```

#### 発生状況
- dependabotのつくったブランチの中で作業を行なった後、他のブランチに移動して`$ bundle install`を実行
- 再度元のブランチに戻った際に発生

### ホームに`.gitignore`を追加したい
```
# ~/.gitconfig

[core]
  excludesfile = ~/.gitignore
```
- `git`コマンドが使える全てのディレクトリに対してignoreする対象のファイルを指定できる
  - Ex. `.DS_Store` / `tags` / `.envrc`

### `fatal: could not read Username for 'https://github.com': terminal prompts disabled`
- 解決: パーソナルアクセストークンを`.gitconfig`に設定
  - GitHub > Developer settings > Generate new token
    - `repo`にチェックを入れる
  - `$ git config --global url."https://パーソナルアクセストークン:x-oauth-basic@github.com/".insteadOf "https://github.com/"
`

#### 発生状況
- Macのローカルの`.vimrc`に新しいVimプラグインを追加して`:PlugInstall`を実行(vim-plug)
