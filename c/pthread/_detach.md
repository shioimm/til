# スレッドのデタッチ
### `pthread_detach(3)`
- 指定のスレッドをjoinさせず、終了時に自動的に破棄するようにさせる

#### 引数
- `thread`を指定する
  - `thread` - 指定のスレッドのスレッドID

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

## 参照
- 詳解UNIXプログラミング第3版 11. スレッド
- 詳解UNIXプログラミング第3版 12. スレッドの制御
- Linuxプログラミングインターフェース 29章
