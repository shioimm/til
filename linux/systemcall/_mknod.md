# mknod(2)
- 特殊ファイルを作成する

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

mknod("fifo", S_IFIFO | 0664, 0) // FIFOを作成

open("fifo", O_RDONLY);
open("fifo", O_WRONLY);
```
