# Single Threaded Execution
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第1章

## TL;DR
- 一つのスレッドのみが処理を実行する
- スレッドが対象の処理に対してロックを獲得することにより(排他制御)、
  複数のスレッドが同時に処理を行おうとすることを避ける

## 要素
### SharedResource
- 複数のスレッドが同時にアクセスしうる共有資源

#### SharedResourceの持つ処理
- safeMethod
  - 複数のスレッドから同時に実行されても問題ない処理
- unsafeMethod
  - 複数のスレッドから同時に実行されると問題が発生する処理
  - 処理を行う単一のスレッドによる排他制御が必要
  - クリティカルセクション - 排他制御が必要な範囲

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
- OOPの場合継承によりSharedResourceの安全性が損なわれる場合がある(継承異常)

## パフォーマンス
- ロックの獲得には時間がかかる
  -> ロックが必要なSharedResourceを減らす
- スレッド同士の処理の衝突によって待ち時間が発生する
  -> クリティカルセクションを小さくすることでスレッド衝突の確率を下げる

## 関連するパターン
- Guarded Suspention
- Read-Write Lock
- Immutable
- Thread-Specific Storage
