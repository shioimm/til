# perf
- 参照: [perf: Linux profiling with performance counters](https://perf.wiki.kernel.org/index.php/Main_Page)
- 参照: []()

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

## Get Started
- カーネルのバージョンを含むパッケージを指定してインストールする必要がある
```
$ sudo apt install linux-tools-common linux-tools-$(uname -r)
```

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
### `perf stat`
- `perf stat`の実行
```
$ sudo perf stat 計測したいプログラム
```

- `perf stat`の実行(詳細なカウンタの値を表示する)
```
$ sudo perf stat -d 計測したいプログラム
```

- 実行中のプロセスにアタッチする
```
$ sudo perf stat -p プロセスID
```

- ホスト全体の計測
```
$ sudo perf stat -a
$ sudo perf stat -a sleep 10 # 所定の時間の間計測する
```

### `perf top`
- 実行しているプログラムの統計情報を動的に表示する
```
$ sudo perf top 計測したいプログラム --stdio
```

### `perf record`
- 実行しているプログラムの統計情報の詳細をperf.dataに蓄積する
```
$ sudo perf record ruby json.rb
```

- perf.dataを表示する
```
$ sudo perf report --stdio
```

### [事例]Apache HTTPサーバーのCPUを計測する
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
