# ベンチマークツール
#### ネットワーク
- `iperf`
- `nerperf`

#### ストレージ
- `filebench`
- `fio`
- `iozone`
- `dbench`

#### Webサーバー
- `ab`
- `siege`
- `wrk`
- `httperf`
- `jmeter`

#### OS
- `vmstat` / `iostat` / `dsat` - 一定時間毎のリソースの使用状況を出力する
- `sar` - 10分毎にデータを取得して保存する
- `munin` - munin-nodeデーモンを使用して複数のサーバーのデータを取得する
- `cacti` `gri` - snmpでデータを取得して保存し、グラフ化する
- `influxdb` - 時系列データベースソフトウェア

## 実行環境
- タイミング
  - ホットスタート
  - コールドスタート
- ネットワーク
  - `tc`
