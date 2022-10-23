# bpftrace
- BPFを利用したトレーシングツール
- トレーシング処理をDSLで記述する

```
<Prove> /<Filter>/{<処理>}
```

#### e.g. `print_comm.bt`
```
#/usr/bin/env bpftrace

tracepoint:syscalls:sys_enter_execve {
  printf("%s\n", comm);
}
```

```
# chmod +x print_comm.bt
# ./print_comm
```
