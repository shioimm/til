# fio
- ディスクの性能を測定する
  - IOPS (Input Output Per Second) - 1秒あたりのI/O実行回数
  - スループット - 一定時間あたりにI/O可能なファイルサイズ
  - レイテンシ - 読み書きなどの処理を行う際に発生する遅延

```
$ fio -filename=./<FileName> -direct=1 -rw=read -bs=4k -size=2G -runtime=10 -group_reporting -name=file

# iops - IOPS
# bw (band witdh) - スループット
# lat (latency) - レイテンシ (clat = I/Oを行うコマンドを実行してから応答が返るまでの時間)
```

## オプション
- `filename - 作成するファイル名・パス
- `direct - non-buffered I/Oで計測する
- `rw - read / write
- `bs - I/Oで利用するブロックのサイズ
- `size - 当該ジョブの各スレッドのファイルI/Oの合計サイズ
- `runtime - 実行時間 (秒)
- `numjobs` - ジョブ数
- `group_reporting` - `numjobs`で処理した結果の統計
- `name` - ジョブ名

## 参照
- [fio - Flexible I/O tester](https://fio.readthedocs.io/en/latest/fio_doc.html)
- 達人が教えるWebパフォーマンスチューニング 〜ISUCONから学ぶ高速化の実践 P238
