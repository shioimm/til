# massif
- ヒープの利用状況を分析する

```
$ valgrind --tool=massif ./prog # => massif.out.<pid>ファイルが出力される

# 分析結果を出力
$ ms_print massif.out.<pid>
```
