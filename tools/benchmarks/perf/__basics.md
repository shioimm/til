# perf
- Linuxの`perf`コマンド (`tools/perf`に含まれる)
- プログラムの実行時のパフォーマンスを計測する

#### 計測ポイント
- CPU performance counters
  - CPUハードウェアレジスタ
  - 命令の実行、キャッシュミスの発生、分岐の予測ミスなどハードウェアにおけるイベントを計測する
- トレースポイント
  - コード内の論理的な場所に配置される計測ポイント
    - システムコール、TCP/IPイベント、ファイルシステム操作など
- Kprobes
  - 実行中のカーネルにおけるブレークポイント
- Uprobes(dynamic tracing)
  - ユーザ空間のアプリケーションにおけるブレークポイント

## 参照
- [perf: Linux profiling with performance counters](https://perf.wiki.kernel.org/index.php/Main_Page)
- Webで使えるmrubyシステムプログラミング入門
