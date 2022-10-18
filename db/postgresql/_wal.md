# WAL (Write Ahead Log)
- 更新操作を記録するログ
  - どのリソースに対する操作か (e.g. HEAP, Transaction, Btree)
  - どんな操作か (e.g. `INSERT`, `UPDATE`, `DELETE`, `COMMIT`, `ROLLBACK`, `INSERT_LEAF`)
  - どのTx内での操作か
  - どのページへの操作か
- DBクラッシュ時、DBに保存されるデータの不整合を解消するために用いられる
- `/var/lib/pgsql/<VersionNum>/data/pg_wal/`以下にバイナリファイルとして保存される
- メモリ (WALバッファ) に書き込まれた後、非同期でディスクに保存される

## 参照
- [PostgreSQL WALログの仕組みとタイミングを理解したい](https://www.kimullaa.com/posts/201910271500/)
