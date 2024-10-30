# `PRI_TIMET_PREFIX`
- `printf`などで`time_t`型の値を表示する際に使用するフォーマット指定子マクロ

```c
struct timeval *at;
gettimeofday(at);
printf("at->tv_sec: %"PRI_TIMET_PREFIX"d\n", at->tv_sec);
printf("at->tv_usec: %d\n", (int)at->tv_usec);
```
