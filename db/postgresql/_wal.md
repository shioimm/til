# WAL (Write Ahead Log)
- 先行書き込みログ (更新操作を記録するログ)
  - どのリソースに対する操作か (e.g. HEAP, Transaction, Btree)
  - どんな操作か (e.g. `INSERT`, `UPDATE`, `DELETE`, `COMMIT`, `ROLLBACK`, `INSERT_LEAF`)
  - どのTx内での操作か
  - どのページへの操作か
- DBクラッシュ時、DBに保存されるデータの不整合を解消するために用いられる
- `/var/lib/pgsql/<VersionNum>/data/pg_wal/`以下に固定長16MBのバイナリファイルとして保存される
- アーカイブされたWALファイルはチェックポイント時に再利用または削除される

#### 更新リクエスト時の動作フロー
1. クライアントからの更新リクエスト
2. 更新ログがメモリ (WALバッファ) に書き込まれる
3. トランザクションがコミットされる
4. 非同期でWALバッファの内容がWALファイルに書き込まれる

## 参照
- [PostgreSQL WALログの仕組みとタイミングを理解したい](https://www.kimullaa.com/posts/201910271500/)
