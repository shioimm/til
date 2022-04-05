# `const`
- 読み出し専用

```c
// c is pointer to read-only char
const char *c;
 c = NULL; // コンパイルエラーにならない
*c = NULL; // コンパイルエラーになる

// c is read-only pointer to char
char * const c;
 c = NULL; // コンパイルエラーになる
*c = NULL; // コンパイルエラーにならない


// c is read-only pointer to read-only char
const char * const c;
 c = NULL; // コンパイルエラーになる
*c = NULL; // コンパイルエラーになる
```

| ポインタ型             | e.g.                    | ポインタ自身 | 参照先   |
| -                      | -                       | -            | -        |
| 非定数へのポインタ     | `int *foo`              | 再代入○      | 再代入○  |
| 定数へのポインタ       | `const int *foo`        | 再代入○      | 再代入×  |
| 非定数への定数ポインタ | `int *const foo`        | 再代入×      | 再代入○  |
| 定数への定数ポインタ   | `const int * const foo` | 再代入×      | 再代入×  |

## 参照
- 詳説Cポインタ
