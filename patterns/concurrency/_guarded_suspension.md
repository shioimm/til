# Guarded Suspension
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第3章

## TL;DR
- GuardedObjectに対する処理において、
  ガード条件が満たされている場合、スレッドが処理を実行する
  ガード条件が満たされていない場合、条件が満たされるまでスレッドを待たせる
  - 「待つ」処理(`wait`)と「通知する」処理(`signal`)を含む
  - ガード条件: リソースの状態が適切かどうか

### 文脈
- 複数のスレッドがリソースを共有しているとき

### 問題
- 各スレッドがリソースに同時にアクセスすると、リソースの安全性が確保されない

### 解決方法
- ガード条件によってリソースの状態が適切かどうかを表現する
- 安全性を失う恐れがある処理を行う前に、ガード条件が満たされているかどうかの判定を行う
  - ガード条件が満たされている場合、処理を実行する
  - ガード条件が満たされていない場合、条件を満たすまでスレッドを待たせる

### Guarded Suspensionの類似パターン
- Guarded Wait
- Busy Wait
- Spin Lock
- Polling

## 要素
### GuardedObject
- ガード処理とガード条件を満たす処理を持つリソース
  - ガード条件が満たされていればすぐに実行される
  - ガード条件が満たされていなければ条件が満たされるまで待つ
  - ガード条件の真偽はGuardedObjectの状態によって変化する
- ガード条件の判定を行う際および判定後に状態を変化させる際に
  Single Threaded Executionを使用する

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
  - ガード条件が満たされておらず、スレッドにロックを獲得させる場合
- Balking
  - ガード条件が満たされておらず、スレッドを待たせずすぐに返す場合
