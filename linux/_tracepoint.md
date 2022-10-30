# Linux Kernel Tracepoint
- カーネル内で発生するイベントにフックして処理を追加する仕組み

#### 利用可能なイベント一覧

```
$ cat /sys/kernel/debug/tracing/available_events
```

#### tracefs
- Tracepointを操作することができるファイルシステム

## 参照
- [Linux Tracepoint とは何か？](https://www.kimullaa.com/posts/202007221323/)
- [Taming Tracepoints in the Linux Kernel](https://blogs.oracle.com/linux/post/taming-tracepoints-in-the-linux-kernel)
