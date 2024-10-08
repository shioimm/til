# sar(1)
- CPU、メモリの使用率、ディスクI/Oの状態などを表示する
  - 過去の統計データに遡ってアクセスする (デフォルト)
  - 現在実行中のデータを周期的に確認する
  - `-P <論理CPU番号>`オプションで統計を取る対象の論理CPUを指定できる
- sysstatパッケージに含まれる

#### CPU使用率

```
$ sar -u <間隔秒> <実行する回数>

# user   - ユーザーモードでCPUが消費された時間の割合
# nice   - スケジューリングの優先度を変更したプロセスがユーザーモードでCPUを消費した時間の割合
# system - カーネルモードでCPUが消費された時間の割合
# idle   - アイドル状態で消費した時間の割合
# iowait - ディスクIO待ちのためにCPUがアイドル状態で消化した時間の割合
```

- 何もオプションをつけない場合もCPU使用率が表示される

#### メモリ使用状況

```
$ sar -r <間隔秒> <実行する回数>

# kbmemfree  - 空きメモリ量 (ページキャッシュ・バッファキャッシュ・スワップ領域はカウントしない)
# kbmemuserd - 使用メモリ量
# memused    - メモリ使用率
# kbbuffers  - バッファキャッシュとしての使用メモリ量
# kbcached   - ページキャッシュとしての使用メモリ量
# kbswapfree - スワップ領域の空きメモリ量
# kbswpused  - スワップ領域の使用メモリ量
# kbavail    - 事実上の空きメモリ量 (kbmemfree + kbbuffers + kbcached)
# kbdirty    - ダーティなページキャッシュとバッファキャッシュの量
```

- カーネルはメモリの空きがあるとデータをできる限りキャッシュしようとする
- 実際のメモリ使用量 = kbmemused - (kbbuffers + kbcached)

#### ロードアベレージ
- 実行待ちになっている平均プロセス数

```
$ sar -q <間隔秒> <実行する回数>
```

#### スワップ発生状況

```
# 現在スワップが発生しているかどうか
$ sar -W

# スワップ領域の使用状況
$ sar -S
```

#### ディスクIO状況

```
$ sar -b <間隔秒> <実行する回数>

# tps     - 一秒あたりのIO読み書きリクエスト数
# rtps    - 一秒あたりのIO読みリクエスト数
# wtps    - 一秒あたりのIO書きリクエスト数
# bread/s - 一秒あたりに読み込まれたブロック数
# bwrtn/s - 一秒あたりに書き込まれたブロック数
```

#### 記録済みの監視情報を見る

```
$ sar -f var/log/sa/ログファイル名
```

### sysstat
- CPU、メモリの使用率、ディスクI/Oの状態などを監視・記録する監視ツールのパッケージ
- バックグラウンドでカーネルからレポートを収集し保存するプログラムsadcが付属する
  - sysstatパッケージをインストールすることでsadcが自動的に動作するようになる
- `/var/log/sa/`配下にsaファイルとsarファイルを作成する
  - sa - 定期的に監視情報を記録していくバイナリファイル
  - sar - saファイルをテキスト形式に変換したファイル

## 参照
- [sysstat (sar) の RHEL8 での変更点や設定方法などのトピック](https://tech-lab.sios.jp/archives/18604)
- Web開発者のための大規模サービス技術入門
