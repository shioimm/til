# `#include <string.h>`
#### `strcat`

```c
char *strcat(char *s1, const char *s2);
```

- s1に対してs2を連結する
- s1は`strlen(s1) + strlen(s2)`バイト分のメモリバッファを保持している必要がある

```c
char *foo = "FOO";
char *bar = "BAR";
char *buf = malloc(strlen(foo) + strlen(bar) + 1);

strcpy(buf, foo);
strcat(buf, bar);
```

#### `strcmp`

```c
int strcmp(const char *s1, const char s2);

// 負数 - s1 < s2
// ゼロ - s1 == s2
// 正数 - s1 > s2
```

```c
// strの参照する文字列と"FOO"の先頭アドレスの参照する文字列 ("FOO") の比較
strcmp(str, "FOO");

// strの先頭アドレスと"FOO"の先頭アドレスの比較
str == "FOO";
```

#### `strcpy`

```c
char *strcpy(char *dst, const char *src);
```

#### `strlen`

```c
size_t strlen(const char *s);
```
