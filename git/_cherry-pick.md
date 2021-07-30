## `git cherry-pick`
- 対象のコミットのみを取り出すことができる

### 事例
- 特定のコミットを他のブランチに切り出したい
```sh
$ git log // 対象のコミットIDを確認
$ git checkout -b new-branch
$ git cherry-pick 対象のコミットID
$ git add .
$ git commit
```
