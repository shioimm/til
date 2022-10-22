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
   eBPFプログラムを対象のProbeにアタッチ
5. (カーネル空間)
   eBPFプログラムがアタッチされたProbe Eventが発生
6. (カーネル空間)
   eBPF Executorがマシンコードをロードし実行、処理結果をBPF Mapやperf bufferへ格納
7. (ユーザー空間)
   ユーザープログラムがBPF Mapやperf bufferを参照してeBPFプログラムの実行結果を取得

### Probe (イベントが発生する、トレース可能な場所) の種類
#### [カーネルトレーシング)] kprobes
- カーネル空間で実行される命令に動的にトラップを設定し、その実行前にBPFプログラムを実行する
- 設定したトラップに到達するとBPFプログラムを実行し、その後元の命令に戻る
- 安定したABIを提供しておらず、カーネルのバージョンごとに互換性が保証されていない
- 対象の関数のアドレスや関数シンボルが必要

#### [ユーザープログラムトレーシング] uprobes
- ユーザー空間で実行されるプログラムに動的にトラップを設定し、その実行前にBPFプログラムを実行する
- 設定したトラップに到達するとBPFプログラムを実行し、その後元の命令に戻る
- 安定したABIを提供しておらず、カーネルのバージョンごとに互換性が保証されていない
- 対象の関数のアドレスや関数シンボルが必要

#### [カーネルトレーシング] tracepoint
- カーネルに事前に定義されているトラップ
- tracefs (カーネルのデバッグ情報にアクセスするための仮想ファイルシステム) を利用する
  - `/sys/kernel/debug/tracing/`にマウントされる
  - トレース可能なイベントの一覧は`/sys/kernel/debug/tracing/available_events`に記載されている
  - イベントを操作するインターフェースは`/sys/kernel/debug/tracing/events/`以下にイベントごとに存在する

#### [ユーザープログラムトレーシン] USDT (User Statically Defined Tracepoints)
- ユーザー空間のアプリケーション自体にtracepointを設置してトレースを行う
- アプリケーションのトレースを行いたい場所に`DTRACE_PROBEn`マクロを記述することで利用できる
- トレースプログラムが動作すると`DTRACE_PROBEn`マクロの箇所がint3c命令に変更され、トラップされる

### Program Type (フック可能なカーネルイベント) の種類
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

#### トレーシング
- `BPF_PROG_TYPE_PERF_EVENT` - determine whether a perf event handler should fire or not
- `BPF_PROG_TYPE_KPROBE` - determine whether a kprobe should fire or not
- `BPF_PROG_TYPE_TRACEPOINT` - determine whether a tracepoint should fire or not

#### Cgroups
- `BPF_PROG_TYPE_CGROUP_SKB` - a network packet filter for cgroups
- `BPF_PROG_TYPE_CGROUP_SOCK` - a network packet filter for cgroups that is allowed to modify socket options
- `BPF_PROG_CGROUP_DEVICE` - determine if a device operation should be permitted or not

### BPF Map
- カーネル空間とユーザー空間の間でデータを共有するためのストレージ
- 配列、ハッシュマップ、キュー、スタック、リングバッファなどの様々な種類のデータ構造が用意されている

## 参照
- [eBPFに3日で入門した話](https://caddi.tech/archives/3880)
- SoftwareDesign 2020年10月号
- [Program Types](https://github.com/iovisor/bcc/blob/master/docs/kernel-versions.md#program-types)
- [Linux eBPFトレーシング技術の概論とツール実装](https://blog.yuuk.io/entry/2021/ebpf-tracing)
