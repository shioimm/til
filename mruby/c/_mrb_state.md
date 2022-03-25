# `mrb_state`
- mruby VMの状態や各種変数などを格納した構造体
- `mrb_state`構造体の変数を引き回すことによってmrubyはプログラムを実行する
- `#include <mruby.h>`

#### メモリ確保に関するメンバ

```c
mrb_allocf  allocf;    // メモリを確保する関数へのポインタ (デフォルトではmrb_default_allocf)
void       *allocf_ud; // allocfに渡すデータ (デフォルトでは常にNULL)
```

#### コンテキストに関するメンバ

```c
struct mrb_context *c;       // VMを動かすためのcontext構造体へのポインタ
struct mrb_context *root_c;  // 起動時のFiberのcontext構造体
struct iv_tbl      *globals; // グローバル変数テーブルへのポインタ
```

#### 例外処理に関するメンバ

```c
struct mrb_jmpbuf *jmp; // 例外発生時のCのスタックの巻き戻し先を格納する
struct RObject    *exc;
struct RClass     *eException_class;     // 例外クラスへのポインタ
struct RClass     *eStandardError_class; // StandardError例外クラスへのポインタ
struct RObject    *nomem_err;            // メモリ不足時のNoMemoryError例外オブジェクトへのポインタ
struct RObject    *stack_err;            // SystemStackError例外オブジェクトへのポインタ
struct RObject    *arena_err;            // arena overflow error例外オブジェクトへのポインタ
```

#### クラスオブジェクトに関するメンバ

```c
struct RObject *top_self;
struct RClass  *object_class;
struct RClass  *class_class;
struct RClass  *module_class;
struct RClass  *proc_class;
struct RClass  *string_class;
struct RClass  *array_class;
struct RClass  *hash_class;
struct RClass  *range_class;
struct RClass  *float_class;
struct RClass  *integer_class;
struct RClass  *true_class;
struct RClass  *false_class;
struct RClass  *nil_class;
struct RClass  *symbol_class;
struct RClass  *kernel_module;
```

#### メモリ管理に関するメンバ

```c
mrb_gc gc; // mrb_gc構造体
```

#### シンボルに関するメンバ

```c
mrb_sym      symidx;       // 現在割り当てられている最大のシンボルの番号
const char **symtbl;       // シンボルの値からシンボルの名前を返す配列
uint8_t     *symlink;
uint8_t     *symflags;
mrb_sym      symhash[256];
size_t       symcapa;      // symtblの大きさ
char         symbuf[8];
```

#### ユーザ定義データ

```c
void *ud;
```

#### ユーザ定義終了関数

```c
mrb_atexit_func atexit_stack[MRB_FIXED_STATE_ATEXIT_STACK_SIZE]; // 終了時に呼ばれる関数の配列
mrb_atexit_func *atexit_stack; // 終了時に呼ばれる関数へのポインタ
uint16_t atexit_stack_len;     // 終了時に呼ばれる関数の数
```

## 参照
- [`typedef mrb_state`](https://github.com/mruby/mruby/blob/master/include/mruby.h#L255)
- [`mrb_state` 解説(必ずしも徹底ではない)](https://qiita.com/miura1729/items/822a18051e8a97244dc3)
