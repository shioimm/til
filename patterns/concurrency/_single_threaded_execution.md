# Single Threaded Execution
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第1章

## TL;DR
- SharedResourceに対する処理において、
  ガード条件が満たされている場合、すべてのスレッドが処理を実行する
  ガード条件が満たされていない場合、一つのスレッドのみが実行する
  - 処理を実行するスレッドがSharedResourceに対してロックを獲得する(排他制御)
    - ガード条件: SharedResourceに対してスレッドセーフな処理を行おうとしているかどうか

### 文脈
- 複数のスレッドがリソースを共有しているとき

### 問題
- 各スレッドがリソースに同時にアクセスすると、リソースの安全性が確保されない

### 解決方法
- クリティカルセクション(リソースが不安定な状態になる範囲)を定める
- クリティカルセクションは一つのスレッドだけが実行できるようにガードする

## 要素
### SharedResource
- 複数のスレッドが同時にアクセスしうる共有資源

#### SharedResourceに対する処理の分類
- スレッドセーフな処理
  - 複数のスレッドから同時に実行されても問題ない処理
- 非スレッドセーフな処理
  - 複数のスレッドから同時に実行されると問題が発生する処理
  - 処理を行う単一のスレッドによる排他制御が必要

## 適用可能性
- 複数のスレッドがプログラムを実行する場合
- 複数のスレッドから処理がアクセスされる場合
- SharedResourceの状態が変化する可能性がある場合
- 安全性を保つ必要がある場合

## 生存性
- Single Threaded Executionはデッドロックを起こす可能性がある

### デッドロックが発生する条件
- 複数のSharedResourceがある
- スレッドがあるSharedResourceのロックを取ったまま
  他のSharedResourceのロックを取りに行こうとする
- SharedResourceのロックを取る順序が定まっていない

## 再利用性
- OOPの場合、継承によりSharedResourceの安全性が損なわれる場合がある(継承異常)

## パフォーマンス
- ロックの獲得には時間がかかる
  -> ロックが必要なSharedResourceを減らす
- スレッド同士の処理の衝突によって待ち時間が発生する
  -> クリティカルセクションを小さくすることでスレッド衝突の確率を下げる

## 関連するパターン
- Guarded Suspention
  - ガード条件が満たされておらず、スレッドを待たせる場合
- Balking
  - ガード条件が満たされておらず、スレッドを待たせずすぐに返す場合
- Read-Write Lock
  - スレッドの役割がReader / Writerに分かれている場合
- Immutable
  - SharedResourceが状態変化しない場合
