# Guarded Suspension
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第3章

## TL;DR
- 条件が満たされるまで処理を実行せず、処理の手前でスレッドを待たせる
  - 「待つ」処理(`wait`)と「通知する」処理(`signal`)を含む
- 条件付きの同期処理
- Mutexと条件変数を使用する

### Guarded Suspensionの類似パターン
- Guarded Wait
- Busy Wait
- Spin Lock
- Polling

## 要素
### GuardedObject
- ガードされた処理とガード条件を満たす処理を持つオブジェクト
  - ガード条件が満たされていればすぐに実行される
  - ガード条件が満たされていなければ条件が満たされるまで待つ
  - ガード条件の真偽はGuardedObjectの状態によって変化する

## 生存性
- `signal`処理が漏れるとスレッドの処理は先に進まず、生存性が失われる
- `wait`処理にタイムアウト設定をする

## 再利用性
- `wait` / `signal`処理を隠蔽することで再利用性を上げる

## 関連するパターン
- Single Threaded Execution
- Balking
- Producer-Consumer
- Future
