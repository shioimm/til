# `$ sudo perf record` / `$ sudo perf report`
- record - イベントを記録し`perf.data`に出力・表示する
- report - プロセスや関数によりイベントを分解す

```
$ sudo perf record -F 99 -p <PID> -g # -> perf.dataの作成

$ perf report -g --stdio # perf.dataの出力
```

## 参照・引用
- [perf　パフォーマンス測定　その１](https://ameblo.jp/softwaredeveloper/entry-11967982906.html)
- [perf: Linux profiling with performance counters](https://perf.wiki.kernel.org/index.php/Main_Page)
- Webで使えるmrubyシステムプログラミング入門
