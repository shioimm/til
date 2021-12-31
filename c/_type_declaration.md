# 型宣言
1. 識別子 (変数名または関数名) を主語とする
2. 識別子に近い方から優先順位に従って派生型 (ポインタ、配列、関数) を解釈する
3. 派生型を of または to または returning で連結する
4. 型指定子を追加する

#### 派生型の優先順位 (降順)
1. 宣言をまとめるための括弧 `()`
2. 配列を意味する`[]`、関数を意味する`()`
4. ポインタを意味する `*`

```c
// arr is array[10] of array[3] of int
int arr[10][3]

// arr is array[10] of pointer to int
int *arr[10]

// func_p is a pointer to a function(double) returning int
int(*func_p)(double);

// p is pointer to array[5] of int
int (*p)[5];

// p is array[5] of pointer to function(int x) returning int
int (*p[5])(int x);
```

## 参照
- 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
