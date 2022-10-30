# bpftrace
- BPFを利用したトレーシングツール
- トレーシング処理をDSLで記述する

```
<Probe対象> /<Filter>/{<処理>}
```

#### Probe対象をリストアップする

```
$ sudo bpftrace -l '*<トレーシングするシステムコール名やカーネル関数名>*'
```

#### e.g. システムコールexecve(2)をトレースする

```
$ sudo bpftrace -e '
  tracepoint:syscalls:sys_enter_execve {
    printf("%s %s\n", comm, str(args->filename));
  }
'
```

あるいは

```c
// print_comm.bt
#/usr/bin/env bpftrace

tracepoint:syscalls:sys_enter_execve {
  printf("%s %s\n", comm, str(args->filename));
}

// # chmod +x print_comm.bt
// # ./print_comm
```
