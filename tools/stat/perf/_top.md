# `$ sudo perf top`
- 実行中のプログラムの統計情報を関数単位でcpu使用率の高い順に表示

```
$ sudo perf top # システム全体を計測

$ sudo perf top -p <PID> # 特定のプロセスを計測
```

## 参照・引用
- [perf　パフォーマンス測定　その１](https://ameblo.jp/softwaredeveloper/entry-11967982906.html)
- [perf: Linux profiling with performance counters](https://perf.wiki.kernel.org/index.php/Main_Page)
- Webで使えるmrubyシステムプログラミング入門
