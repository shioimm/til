## git rebase

### --abort

- rebaseを中止し、HEADを元のブランチに戻す

```console
git rebase --abort
```

### git rebase master中にGemfile.lockが競合した場合

- masterのGemfile.lockを採用する
```console
git checkout --ours Gemfile.lock
```

- 作業ブランチのGemfile.lockを採用する
```console
git checkout --theirs Gemfile.lock
```
