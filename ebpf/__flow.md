# 動作フロー
1. (ユーザー空間)
   eBPFプログラムを含むユーザープログラムがeBPFプログラムのソースコードをコンパイルし、eBPFバイトコードに変換
2. (ユーザー空間)
   bpf(2)システムコールを呼び出す
3. (カーネル空間)
   BPF VerifierがeBPFバイトコードの安全性を検証
   カーネルをクラッシュさせる可能性がある場合はeBPFバイトコードのロードに失敗
   問題なければeBPFバイトコードをロードしJITコンパイラがマシンコードに変換
4. (カーネル空間)
   eBPFプログラムを対象のイベントにアタッチ
5. (カーネル空間)
   eBPFプログラムがアタッチされたイベントが発生
6. (カーネル空間)
   eBPF Executorがマシンコードをロードし実行、処理結果をBPF Mapやperf bufferへ格納
7. (ユーザー空間)
   ユーザープログラムがBPF Mapやperf bufferを参照してeBPFプログラムの実行結果を取得

## Program Type (フック可能なカーネルイベント)
### Program Typeによって定義されるもの
- BPFプログラムがどこで呼び出されるのか
- BPFプログラムにどんな引数 (コンテキスト) が渡されるのか
- BPFプログラム内から引数のポインタデータは変更可能か
- BPFから呼び出せるヘルパー関数 (`BPF_CALL`できる関数) には何があるのか
- BPFプログラムの戻り値はどのような意味を持つのか

### Program Typeの種類
#### トレーシング
- `BPF_PROG_TYPE_PERF_EVENT` - determine whether a perf event handler should fire or not
- `BPF_PROG_TYPE_KPROBE` - determine whether a kprobe should fire or not
- `BPF_PROG_TYPE_TRACEPOINT` - determine whether a tracepoint should fire or not

#### ソケット操作
- `BPF_PROG_TYPE_SOCKET_FILTER` - a network packet filter
- `BPF_PROG_TYPE_SOCK_OPS` - a program for setting socket parameters
- `BPF_PROG_TYPE_SK_SKB` - a network packet filter for forwarding packets between sockets

##### トンネリング
- `BPF_PROG_TYPE_LWT_*` - a network packet filter for lightweight tunnels

#### 帯域制御
- `BPF_PROG_TYPE_SCHED_CLS` - a network traffic-control classifier
- `BPF_PROG_TYPE_SCHED_ACT` - a network traffic-control action

#### XDP (eXpress Data Path)
- `BPF_PROG_TYPE_XDP` - a network packet filter run from the device-driver receive path

#### Cgroups
- `BPF_PROG_TYPE_CGROUP_SKB` - a network packet filter for cgroups
- `BPF_PROG_TYPE_CGROUP_SOCK` - a network packet filter for cgroups that is allowed to modify socket options
- `BPF_PROG_CGROUP_DEVICE` - determine if a device operation should be permitted or not

## BPF Verifierの検証項目
- ループが存在しないこと
- 未初期化のレジスタを利用しないこと
- コンテキストの許可範囲のみアクセスしていること
- 境界を超えたメモリアクセスをしないこと
- メモリアクセスのアラインメントが正しいこと

## BPF Map
- カーネル空間とユーザー空間の間でデータを共有するためのストレージ
- 配列、ハッシュマップ、キュー、スタック、リングバッファなどの様々な種類のデータ構造が用意されている
- BPFプログラムからは外部関数呼び出し機能を利用することによってアクセス可能
- ユーザーアプリケーションからはシステムコールを利用することによってアクセス可能

## 参照
- [eBPFに3日で入門した話](https://caddi.tech/archives/3880)
- SoftwareDesign 2020年10月号
- [Program Types](https://github.com/iovisor/bcc/blob/master/docs/kernel-versions.md#program-types)
- [Linux eBPFトレーシング技術の概論とツール実装](https://blog.yuuk.io/entry/2021/ebpf-tracing)
