# ワンタイムイニシャライゼーション
### `pthread_once(3)`
- ワンタイムイニシャライゼーションの設定を行う

#### 引数
- `*once_control`、`*init`を指定する
  - `*once_control` - `*init`を実行するかしないか状態を示す`pthread_once_t`へのポインタ
  - `*init` - 実行する初期化関数へのポインタ

```c
// *once_controlの設定

pthread_once_t once_var = PTHREAD_ONCE_INIT

// *initの設定

void init(void)
{
  // 実行する処理
}
```

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `pthread_key_create(3)`
- スレッド固有データのためのグローバル配列のインデックスを
  スレッド固有データのキーとしてマークし、確保する
- キーに対応するスレッドが終了すると自動的にデストラクタが実行される

#### 引数
- `*key`、`*destructor`を指定する
  - `*key` - スレッド固有データのキーを格納する`pthread_key_t`へのポインタ
  - `*destructor` - デストラクタ関数へのポインタ

```c
// *destructorの設定

void dest(void *value)
{
  // *valueのメモリ領域を解放する処理
}
```

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

### `pthread_setspecific(3)` / `*pthread_getspecific(3)`
- `pthread_setspecific(3)` - 自スレッドのキーに対応する`value`を設定する
- `pthread_getspecific(3)` - 自スレッドのキーに対応する`value`を返す

#### 引数
- `pthread_setspecific(3)` - `*key`、`*value`を指定する
  - `*key` - スレッド固有データのキーを格納する`pthread_key_t`へのポインタ
  - `*value` - 自スレッドが割り当てたメモリ領域へのポインタ(デストラクタの引数)
- `pthread_getspecific(3)` - `*key`を指定する
  - `*key` - スレッド固有データのキーを格納する`pthread_key_t`へのポインタ

#### 返り値
- 数値0を返す
  - エラー時は正のエラー番号を返す

## 参照
- 詳解UNIXプログラミング第3版 11. スレッド
- 詳解UNIXプログラミング第3版 12. スレッドの制御
- Linuxプログラミングインターフェース 29章
