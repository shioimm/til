# スレッドID
### `pthread_self(3)`
- スレッドIDを返す

#### 返り値
- 自スレッドのIDを返す

### `pthread_equal(3)`
- 二つのスレッドIDを比較し、等しいかどうかを検査する

#### 引数
- `t1`、`t2`を指定する

#### 返り値
- 等しい場合は数値0以外を返す
- 等しくない場合は数値0を返す

## 参照
- 詳解UNIXプログラミング第3版 11. スレッド
- 詳解UNIXプログラミング第3版 12. スレッドの制御
- Linuxプログラミングインターフェース 29章