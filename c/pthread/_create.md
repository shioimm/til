# スレッドの作成
### `pthread_create(3)`
- スレッドを新規に作成する
- スレッド作成後、新しく作成されたスレッドと呼び出し側のスレッドのうち
  どちらが先に動き出すかについては保証がない

#### 引数
- `*thread`、`*attr`、`*start`、`*arg`を指定する
  - `*thread` - 作成するスレッドのスレッドIDを格納する`pthread_t`へのポインタ
  - `*attr` - 作成するスレッドのスレッド属性
  - `*start` - 作成するスレッドが開始する関数
  - `*arg` - `*start`への引数

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

## 参照
- 詳解UNIXプログラミング第3版 11. スレッド
- 詳解UNIXプログラミング第3版 12. スレッドの制御
- Linuxプログラミングインターフェース 29章
