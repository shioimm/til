# rebase時、間違えて--abortした際の変更を確認する
```
$ git rebase -i コミット番号
$ 修正作業
$ git commit --amend
$ git rebase --abort
```

```
$ git reflog
$ git show コミット番号 # 変更内容を表示
```
