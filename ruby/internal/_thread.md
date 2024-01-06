# スレッド関連

```c
// Blocks until the current thread obtains a lock.
// このスレッドがロックを獲得するまで待つ
void rb_nativethread_lock_lock(rb_nativethread_lock_t *lock);
void rb_native_mutex_lock(rb_nativethread_lock_t *lock);

// ロックを解放する
void rb_nativethread_lock_unlock(rb_nativethread_lock_t *lock);
void rb_native_mutex_lock(rb_nativethread_lock_t *lock);

// 使い方
rb_nativethread_lock_lock(rb_nativethread_lock_t lock);
{
  // ロックを獲得してして行いたい処理
}
rb_nativethread_lock_unlock(rb_nativethread_lock_t lock);
```
