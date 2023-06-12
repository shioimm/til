# read / writeロック

```c
#include <pthread.h>

pthread_rwlock_t rwlock;

pthread_rwlock_init(&rwlock, NULL);

pthread_rwlock_rdlock(&rwlock);
pthread_rwlock_tryrdlock(&rwlock);

pthread_rwlock_wrlock(&rwlock);
pthread_rwlock_trywrlock(&rwlock);

pthread_rwlock_unlock(&rwlock);

pthread_rwlock_destroy(&rwlock);
```
