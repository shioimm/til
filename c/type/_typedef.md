# typedef
- 既存のデータ型に新しい名前を付ける

```c
// unsigned char -> uchar
typedef unsigned char uchar;

uchar c;

// struct -> user_table
typedef struct {
  char name[255];
} user_table;

user_table utable;

// 関数ポインタ -> func
typedef void (*func)(int);
func f;
```

- `#define` - プロプロセッサによって解釈される
- `typedef` - コンパイラによって解釈される

## 参照
- 新・C言語入門 シニア編 P50
