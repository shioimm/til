# Read-Write Lock
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第6章

## TL;DR
- ReaderスレッドがSharedResourceに対するRead処理においてReadロックを取得する
  WriterスレッドがSharedResourceに対するWrite処理においてWriteロックを取得する
  - Readロック中、複数スレッドが同時にReadを行うことができる
  - Readロック中、どのスレッドもWriteを行うことはできない
  - Writeロック中、どのスレッドもReadを行うことはできない
  - Writeロック中、どのスレッドもWriteを行うことはできない
- Read-Write LockによってRead-Write conflict / Write-Write conflictを防ぐ

### 文脈
- 複数のスレッドがリソースを共有しているとき
- リソースの状態を参照するだけのスレッド(Reader)と
  リソースの状態を変更するだけスレッド(Writer)が混在しているとき

### 問題
- 各スレッドがリソースに同時にアクセスすると、リソースの安全性が確保されない
- Single Threaded Executionを使用するとスループットが低下する

### 解決方法
- Readerを制御するロックとWriterを制御するロックを提供するRead-Write Lockを用意する
- Read-Write LockがReader-Writer同士 / Writer-Writer同士の排他制御を行う

## 要素
### Reader
- SharedResourceに対してRead処理を行う

### Writer
- SharedResourceに対してWrite処理を行う

### SharedResource
- ReaderスレッドとWriterスレッドが同時にアクセスしうる共有資源

### Read-Write Lock
- SharedResourceがRead処理とWrite処理を実現するためのロック機構
  - Read処理のためにReadLockとReadUnlockを提供する
  - Write処理のためにWriteLockとWriteUnlockを提供する
- 排他制御のためにGuarded Suspensionを使用する
  - ガード条件1: Read処理と同時にWrite処理を行おうとしていないかどうか
  - ガード条件2: Write処理と同時にWrite処理を行おうとしていないかどうか

#### Read-Write conflict / Write-Write conflictを防ぐための動作
- ReaderスレッドがReadロックを確保しようとした時
  - Read中のスレッドがいる場合は待たない
  - Write中のスレッドがいる場合は待つ
- WriterスレッドがWriteロックを確保しようとした時
  - Read中のスレッドがいる場合は待つ
  - Write中のスレッドがいる場合は待つ

## パフォーマンス
- 処理をReadとWriteに分けることで排他制御を分けて考えることができ、
  パフォーマンスを向上させることができる
- Read処理が重い時に有効
- Read処理の頻度がWrite書類の頻度よりも高いときに有効

## 関連するパターン
- Immutable
  - Writerがいない場合
- Before/After
- Strategized Locking
