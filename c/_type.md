# 型
- オブジェクト型 (char、int、配列、ポインタ、構造体、共用体など)
- 関数型
- 不完全型 (構造体タグ、voidなど)

## 型宣言

```c
int (*func_p)(double)

// 1. 識別子 (変数名または関数名) を主語とする
//    -> func_p is
//
// 2. 識別子に近い方から優先順位に従って派生型 (ポインタ、配列、関数) を解釈する
//      (1) 宣言をまとめる括弧 ()
//      (2) 配列を意味する [] または 関数を意味する ()
//      (3) ポインタを意味する * またはメモリアドレスを意味する &
//   -> func_p is pointer to
//   -> func_p is pointer to function(double)
//
// 3. 派生型を of または to または returning で連結し、型指定子を追加する
//   -> func_p is pointer to function(double) returning int
```

```c
// foo is array[3] of int
int foo[3];

// foo is array[10] of array[3] of int
int foo[10][3]

// foo is array[10] of pointer to int
int *foo[10]

// foo is pointer to array[5] of int
int (*foo)[5];

// foo is function(int x) returning int
int foo(int x);

// foo is pointer to function(int x) returning int
int (*foo)(int x);

// foo is array[5] of pointer to function(int x) returning int
int (*foo[5])(int x);

// atexit is function(void (*func)(void)) returning int
//   func is pointer to function(void) returning void
int atexit(void (*func)(void));

// signal is function(int sig, void (*func)(int)) returning pointer to void
//   func is pointer to function(int) returning void
void (*signal(int sig, void (*func)(int)))(int);
```

## 参照
- 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
