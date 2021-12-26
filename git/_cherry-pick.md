# cherry-pick
- 対象のコミットのみを取り出す

```
# 特定のコミットを他のブランチに切り出したい

$ git log // 対象のコミットIDを確認
$ git checkout -b BRANCHNAME
$ git cherry-pick 対象のコミットID
$ git add .
$ git commit
```
