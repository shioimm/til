# スレッドローカル変数

```c
#include <pthread.h>

pthread_key_t key;

pthread_key_create(&key, NULL); // スレッドローカル変数を用意
pthread_setspecific(key, <値>); // (スレッド内) スレッドローカル変数に値をセット
pthread_getspecific(key);       // (スレッド内) スレッドローカル変数から値を取得
```
