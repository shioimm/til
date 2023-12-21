# `clock_gettime()`の結果を標準出力

```c
#include <stdio.h>
#include <time.h>

struct timespec ts;
clock_gettime(CLOCK_MONOTONIC, &ts);
printf("%10ld.%09ld \n", ts.tv_sec, ts.tv_nsec);
```

- `clock_gettime`の第一引数にクロックの種別を渡す
