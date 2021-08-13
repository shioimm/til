# ワーカー数メモリ容量の関係
- Web dyno数 = マシン台数
- ワーカー数 = プロセス数
  - CPUコア数を上限とする
  - 1dynoあたりで使用できるメモリ容量を全ワーカーで分け合う
    - メモリ使用量(MAX) * 現在のワーカー数 < 1dynoの全メモリ容量である場合、ワーカー数を増やせる可能性がある

```
e.g.

dynoタイプ:   Standard-2x(RAM 1024 MB / CPUコア数 2x) (アプリケーション > Resourcesで確認)
ワーカー数:   1 (config/puma.rb / workers ENV.fetch('WEB_CONCURRENCY') { n } で確認)
メモリ使用量: 496MB(MAX) (アプリケーション > Metrics > Memory Usageで確認)

-> ワーカー数を2に増やすことが可能
```
