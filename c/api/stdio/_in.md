# `#include <stdio.h>`
#### `fread`
- streamからsizeバイト分のデータをn個読み込み、ptrへ格納する

```c
size_t fread(void *ptr, size_t size, size_t nitems, FILE *stream);

// void *ptr - 格納先へのポインタ
// size_t size - 格納データサイズ (バイト)
// size_t nitems - 格納データ数
// FILE *stream - 読み込み元ファイルストリームへのポインタ
```

#### `fgets`
- streamから文字列を1行読み込み、sizeバイト分sへ格納する

```c
char *fgets(char *s, int size, FILE *stream)

// char *s - 格納先ポインタ
// int size - 読み込みサイズ
// FILE *stream - 読み込み元ファイルストリーム
```

#### `fscanf`
- streamから文字列を読み込み、formatに従って変数に格納する

```c
int fscanf(FILE *restrict stream, const char *restrict format, ...);

// FILE *stream - 読み込み元ストリーム
// const char *format - 入力フォーマット
// ... - 入力フォーマットで指定された変数
```

#### `scanf`
- 標準出力から文字列を読み込み、formatに従って変数に格納する

```c
int scanf(const char *format, ...);

// const char *format - 入力フォーマット
// ... - 入力フォーマットで指定された変数
```
