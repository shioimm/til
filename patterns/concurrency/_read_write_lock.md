# Read-Write Lock
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第6章

## TL;DR
- 処理をReadとWriteに分ける
  - Read処理を行うスレッドはReadロックを取得する
    - Readロック中、複数スレッドが同時にReadを行うことができる
    - Readロック中、どのスレッドもWriteを行うことはできない
  - Write処理を行うスレッドはWriteロックを取得する
    - Readロック中、どのスレッドもReadを行うことはできない
    - Readロック中、どのスレッドもWriteを行うことはできない
- Read-Write conflict / Write-Write conflictを防ぐためのロック機構(ReadWriteLock)を使用する
  - ロック機構がChannelがGuarded Suspensionを使用する

### conflictを防ぐロック機構の動作
- スレッドがReadロックを確保しようとした時
  - Read中のスレッドがいる場合は待たない
  - Write中のスレッドがいる場合は待つ
- スレッドがWriteロックを確保しようとした時
  - Read中のスレッドがいる場合は待つ
  - Write中のスレッドがいる場合は待つ

## ガード条件
- Read処理と同時にWrite処理を行おうとしていないかどうか
- Write処理と同時にWrite処理を行おうとしていないかどうか

## 要素
### Reader
- SharedResourceに対してReadを行う

### Writer
- SharedResourceに対してWriteを行う

### SharedResource
- ReaderとWriterによって共有されている資源

### ReadWriteLock
- SharedResourceがRead処理とWrite処理を実現するためのロック機構
  - Read処理のためにReadLockとReadUnlockを提供する
  - Write処理のためにWriteLockとWriteUnlockを提供する

## 適用可能性

## 生存性

## 再利用性

## パフォーマンス
- 処理をReadとWriteに分けることで排他制御を分けて考えることができ、
  パフォーマンスを向上させることができる
- Read処理が重い時に有効
- Read処理の頻度がWrite書類の頻度よりも高いときに有効

## 関連するパターン
- Immutable
- Single Threaded Execution
- Guarded Suspension
- Before/After
- Strategized Locking
