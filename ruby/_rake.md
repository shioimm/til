# Rake
## 事例
### Rakeタスクに配列の引数を渡すと'no matches found:'
- 原因: 引数の\[\]がエスケープされていない
- 解決: 引数をエスケープ
```
// Before
$ rake namespace:taskname[args]
```
```
// After
$ rake namespace:taskname\[args\]
```
