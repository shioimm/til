# `#include <stdio.h>`
#### `fwrite`
- ptrからsizeバイトのデータをnitems個入力し、streamへ出力する

```c
size_t fwrite(const void *ptr, size_t size, size_t nitems, FILE *stream);

// const void *ptr - 入力元へのポインタ
// size_t size_t - 入力データサイズ (バイト)
// size_t nitems - 入力データ数
// FILE *fp - 出力先ファイルストリームへのポインタ
```

#### `fprintf`
- formatに従ってstreamへ文字列を出力する

```c
int fprintf(FILE *stream, const char *format, ...);

// FILE *stream - 出力先ファイルストリーム
// const char *format - 出力フォーマット
// ... - 出力フォーマットで指定された変数
```

#### `sprintf`
- formatに従ってstrへ文字列を出力する

```c
int sprintf(char *str, const char *format, ...);

// char *str - 出力先char配列
// const char *format - 出力フォーマット
// ... - 出力フォーマットで指定された変数
```

#### `printf`
- formatに従って標準出力へ文字列を出力する

```c
int printf(const char *format, ...);

// const char *format - 出力フォーマット
// ... - 出力フォーマットで指定された変数
```
