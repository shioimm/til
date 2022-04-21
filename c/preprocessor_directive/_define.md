# #define
- マクロ定義を行う

```c
// #define マクロ名       置換文字列
// #define マクロ名(引数) 引数を含む置換文字列

#define N 100
#define add(a, b)   ((a) + (b))
#define putnum(n)   printf("%d\n", n)
#define catstr(s)   "s = " #s // #演算子 - 引数を文字列として展開する
#define embedstr(s) s = ##s   // ##演算子 - 引数文字列をトークン化する

add(N, 100);    // 100 + 100
putnum(N);      // printf("%d\n", 100);
catstr("str")   // "s =" "str"
embedstr("str") // "s = str"
```

### 定義済みマクロ

| 名前       | 意味                                           |
| -          | -                                              |
| `__FILE__` | 現在処理中のソースファイルの名前を示す文字列   |
| `__LINE__` | 現在処理中のソースファイルの行番号を示す文字列 |
| `__DATE__` | コンパイル日を"MM DD YY"で示す文字列           |
| `__TIME__` | コンパイル時刻を"hh:mm:ss"で示す文字列         |

## #undef
- マクロ定義の除去

```c
#define N 100
#undef  N
#define N 200
```
