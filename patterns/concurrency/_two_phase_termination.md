# Two-Phase Termination
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第10章

## TL;DR
- TerminationRequesterがTerminatorに対して終了要求を出すと、
  Terminatorは終了処理の段階を経て終了する
  - 作業中 -> 終了処理中 -> 終了
- 安全に終了させること(安全性)、必ず終了処理を行うこと(生存性)、
  終了要求を出したらできるだけ早く終了処理に入ること(応答性)がポイントになる
- graceful shutdownを実現するためのパターン

## 要素
### TerminationRequester
- Terminatorに対して終了要求を呼び出す

### Terminator
- TerminationRequesterから終了要求を受けて終了処理を行う
  - TerminationRequesterから終了要求が呼ばれると
    安全性を考慮した上で終了処理状態に入る
  - 終了処理が完了すると終了する
- 終了要求を表現するAPIを提供する
- 終了要求が呼ばれたかどうかを示すフラグを持つ

## 安全性
- 終了要求を受けたスレッドはすぐに終了せず、
  終了要求が呼ばれたかどうかを示すフラグを立てる
- オブジェクトを壊さない安全なポイントでのみ終了処理を開始する

## 生存性
- 中断できる`wait`はすぐに中断し、終了処理へ移行する
- 例外が投げられて終了する場合も終了処理を必ず行う

## 応答性
- 中断できる`sleep`はすぐに中断し、終了処理へ移行する
- 重い処理の前には終了要求が呼ばれたかどうかを示すフラグを確認する

## 関連するパターン
- Before/After
- Multiphase Cancellation
- Multi-Phase Startup
- Balking
