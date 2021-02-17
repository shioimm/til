# Guarded Suspension
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第3章

## TL;DR
- 条件付きの同期処理
- ガード条件が満たされていない場合、条件が満たされるまで処理の手前でスレッドを待たせる
  - 「待つ」処理(`wait`)と「通知する」処理(`signal`)を含む
- GuardedObjectがガード条件のテストを行う際とテスト後、状態を変更する際に
  Single Threaded Executionを使用する
- Mutexと条件変数を使用する

### Guarded Suspensionの類似パターン
- Guarded Wait
- Busy Wait
- Spin Lock
- Polling

## ガード条件
- オブジェクトの状態が適切かどうか

## 要素
### GuardedObject
- ガード処理とガード条件を満たす処理を持つオブジェクト
  - ガード条件が満たされていればすぐに実行される
  - ガード条件が満たされていなければ条件が満たされるまで待つ
  - ガード条件の真偽はGuardedObjectの状態によって変化する

## 適用可能性
- ガード条件が満たされるのを待つ場合
  - ガード条件が満たされるのを待たずにすぐ返す場合はBalkingを使用する

## 生存性
- `signal`処理が漏れるとスレッドの処理は先に進まず、生存性が失われる
- `wait`処理にタイムアウト設定をする

## 再利用性
- `wait` / `signal`処理を隠蔽することで再利用性を上げる

## Guarded Timed(Timeout)
- ガード条件を満たすまで一定時間待つパターン

## 関連するパターン
- Single Threaded Execution
- Balking
- Producer-Consumer
- Future
