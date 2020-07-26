# perf
- 参照: [perf: Linux profiling with performance counters](https://perf.wiki.kernel.org/index.php/Main_Page)

## TL;DR
- Linuxの`perf`コマンド(`tools/perf`に含まれる)
- プログラムの実行時のパフォーマンスを計測する

### 計測ポイント
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

## インターフェース
- `perf stat`
  - イベントカウントを取得する
- `perf record`
  - イベントを記録し`perf.data`に出力・表示する
- `perf report`
  - プロセスや関数によりイベントを分解する
- `perf annotate`
  - アセンブリやソースコードにイベントカウントの注釈を付ける
- `perf top`
  - ライブイベントのカウントを確認する
- `perf bench`
  - 異なるカーネルのマイクロベンチマークを実行する

## Usage
### Apache HTTPサーバーのCPUを計測する
1. 計測するサーバーのワーカープロセスのpidを確認(`$ ps aux | grep apache`)
2. `perf`で計測を開始する(`$ sudo perf stat -p 対象のpid`)
3. Apache Benchでワークロードを発生させる(`$ ab -n 20000 -c 10 対象のホスト名`)
4. `2`で計測していたパフォーマンスカウンタの集計結果を確認

#### 結果
- 引用: [perf　パフォーマンス測定　その１](https://ameblo.jp/softwaredeveloper/entry-11967982906.html)
- task-clock
  - OSが実行プロセスに割り振った実行時間(ms)
- context-switches
  - コンテキストが切り替わった回数
- cpu-migrations
  - CPUを移動した回数
- page-faults
  - ページフォルトが発生した回数
- cycles
 - 使用したCPUサイクル数
- stalled-cycles-frontend
  - フロントエンドで命令が止まったサイクル数(CPU依存)
- stalled-cycles-backend
  - バックエンドで命令が止まったサイクル数(CPU依存)
- instructions
  - リタイアした命令数
- branches
  - 分岐命令の実行回数
- branch-misses
  - 分岐予測をミスした回数
