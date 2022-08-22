# cherry-pick
- 対象のコミットのみを取り出す

```
# 特定のコミットを他のブランチに切り出したい

$ git log // 対象のコミットIDを確認
$ git checkout -b <BranchName>
$ git cherry-pick 対象のコミットID
```

```
# 範囲指定
# e.g. c1 -> c2 -> c3 -> c4 のうちc2 ~ c4をcherry-pick

$ git cherry-pick c1..c4
# 始点の一つ前のコミットIDと終点のコミットIDを指定
```
