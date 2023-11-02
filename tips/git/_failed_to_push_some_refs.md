# `error: failed to push some refs to 'git@github.com:...`

```
$ git push -f origin/dependabot/bundler/xxxx                                                                     ✘ 1
To github.com:Catal/Nozomi.git
 ! [rejected]            dependabot/bundler/xxxx -> dependabot/bundler/xxxx (stale info)
error: failed to push some refs to 'git@github.com:...'
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
