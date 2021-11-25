# DatabaseCleaner
#### Strategies
- :transaction
  - `BEGIN TRANSACTION` -> `ROLLBACK`
  - transactionを張り、終了時にrollback
  - 一般的には一番早いが複数DBでは使用できない
- :truncation
  - `TRUNCATE TABLE`
  - テーブルからすべての行を削除
  - 一般的に:deletionより早い
- :deletion
  - `DELETE FROM`
  - テーブルからレコードを行単位で削除
- :nil
  - クリーンアップを行わない

## 参照
- [DatabaseCleaner/`database_cleaner`](https://github.com/DatabaseCleaner/database_cleaner)
- [Database cleaning and strategies](https://www.bigbinary.com/learn-rubyonrails-book/database-cleaning-and-strategies)
