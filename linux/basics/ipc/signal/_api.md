# API
- 参照: Linuxプログラミングインターフェース 20章

## シグナル動作の変更
### `signal(2)`
- 指定のシグナルの動作を変更する
- `sigaction(2)`よりも設定できる機能が少なく、可搬性も低い

#### 引数
- `sig`、`*handler`を指定する
  - `sig` - 動作を変更するシグナルのマクロ
  - `*handler` - シグナル受信時に実行する関数へのポインタ

```c
// ハンドラとして設定する関数の形式

void handler(int sig)
{
  // 処理内容
}
```

```c
// handlerをtypedefしておくと便利

#define _GNU_SOURCE

typedef void(*sighandler_t)(int);

sighandler_t signal(int sig, sighandler_t handler);
```

#### 返り値
- 変更前のシグナル動作へのポインタを返す
  - エラー時は`SIG_ERR`を返す
