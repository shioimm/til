# perf
- プログラム実行時の性能を計測する
- Linuxの`tools/perf`に含まれる

| サブコマンド    | 用途                                                                  |
| -               | -                                                                     |
| `$ perf list`   | 測定対象となるハードウェア・ソフトウェアイベント一覧を表示            |
| `$ perf stat`   | プログラムのパフォーマンスカウンタを表示                              |
| `$ perf top`    | 実行中のプログラムの統計情報を関数単位でcpu使用率の高い順に表示       |
| `$ perf record` | 測定対象となるハードウェア・ソフトウェアイベントを記録                |

#### 計測ポイント
- CPU performance counters
  - CPUハードウェアレジスタ
  - 命令の実行、キャッシュミスの発生、分岐の予測ミスなどハードウェアにおけるイベントを計測する
- トレースポイント
  - コード内の論理的な場所に配置される計測ポイント
    - システムコール、TCP/IPイベント、ファイルシステム操作など
- Kprobes
  - 実行中のカーネルにおけるブレークポイント
- Uprobes (dynamic tracing)
  - ユーザ空間のアプリケーションにおけるブレークポイント

#### インストール

```
# linux-tools-common + linux-tools-$(uname -r) (カーネルのバージョンを指定) をインストール
$ sudo apt install linux-tools-common linux-tools-$(uname -r)
```

## 参照
- [perf: Linux profiling with performance counters](https://perf.wiki.kernel.org/index.php/Main_Page)
- Webで使えるmrubyシステムプログラミング入門
