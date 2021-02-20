# Immutable
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第2章

## TL;DR
- ImmutableなSharedResourceは複数のスレッドから同時にアクセスすることができる

### 文脈
- 複数のスレッドがリソースを共有しており、リソースの状態が変化することがないとき

### 問題
- Single Threaded Executionを使用するとスループットが落ちてしまう

### 解決方法
- リソースの状態が不変である場合、Single Threaded Executionを使用するのをやめる
- スレッドがリソースを変更できないようにする

## 要素
### SharedResource
- 複数のスレッドが同時にアクセスしうる共有資源

### Immutable
- 複数のスレッドが同時にアクセスしても値が変更されないSharedResource

## 適用可能性
- インスタンスの生成後、状態が変化しない場合
- インスタンスが共有され、頻繁にアクセスされる場合

## 再利用性
- インスタンスの不変性が守られている限り再利用可能

## パフォーマンス
- 同期処理を行わない分パフォーマンスが向上する

## 関連するパターン
- Single Threaded Execution
  - SharedResourceが状態変化する(Immutableではない)場合
- Read-Write Lock
  - スレッドの役割がReader / Writerに分かれており、
    SharedResourceが状態変化するがWriter役が少ない場合
- Flyweight
