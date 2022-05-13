# push
#### --force-with-lease
- push時にローカルrefとリモートrefを比較し、
  ローカルrefの方が新しい場合は成功、リモートrefの方が新しい場合は失敗する
- 実行前にローカルで`$ git fetch origin master`している場合は常に成功する
  - ローカルrefとリモートrefが常に一致するため

```
$ git push --force-with-lease origin main
```
