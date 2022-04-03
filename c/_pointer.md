# ポインタ操作
#### ポインタ型
- アドレスを扱う型
- 他の型に対する派生型 (e.g. `int *p` = int型の変数pへのポインタ型)

#### ポインタ型の値
- メモリアドレスを表す値

#### ポインタ型の変数
- ポインタ型の値 (メモリアドレス) を格納する変数

```c
int  i = 100;
int *p;

// iのメモリアドレスをpへ格納
p = &i;

// メモリアドレスに格納された値 (100) への操作を行う
*p += 200; // 100 + 200 = 300
```

#### メモリアドレスを扱う演算子
- アドレス演算子 `&`
  - 変数のアドレスを求める演算子
- 間接参照演算子 `*`
 - ポインタの指すメモリアドレスに格納された値を扱う
- 添字演算子`[i]`
  - `*(アドレス + i)`のシンタックスシュガー
  - 配列`arr[i][j]`に対する添字アクセス`arr[i][j]`は`*((*(arr + i)) + j)`と同じ

#### ポインタへの読み替え
- 式の中の配列 -> 配列 (のn番目の要素) へのポインタへ読み替えられる
- 関数の引数として渡した配列 -> 配列の先頭要素へのポインタと読み替えられる

## ポインタの間違い
#### 未初期化ポインタ変数の間接演算
```c
int *p;
*p = 999;

// 初期化時にポインタ変数*pに参照先のアドレスが割り当てられていない
// 代入時にポインタ変数*pが指すアドレス領域が空のままであるためエラー
```

#### 未初期化ポインタ変数を引数に渡す
```c
#include <time.h> // time_t time(time_t *t);

time_t *t;
time(t);

// 初期化時にポインタ変数*tに参照先のアドレスが割り当てられていない
// 変数tはどこも指していないためエラー
// time(&t);またはで変数tへのアドレスを渡す
```

#### ローカル変数へのポインタを返り値にする
```c
int *foo()
{
  int x;
  return &x;
}

// return時にローカル変数は消えるため
// 存在しない領域を指すポインタを返すことになりエラー
```

#### ポインタが指す先が未初期化
```c
#include <sys/types.h>
#include <socket.h> // int accept(int s, struct sockaddr *addr, socklen_t *addrlen);

int sock = socket(AF_INET, SOCK_STREAM, 0);
struct sockaddr_storage client_addr;
unsigned int address_size;

accept(sock, (struct sockaddr *)&client_addr, &address_size);

// 変数address_sizeが実際に指し示す先がないためエラー
// unsigned int address_size = sizeof(client_addr);
```

## 参照
- 例解UNIX/Linuxプログラミング教室P69-76
- [苦しんで覚えるC言語](https://9cguide.appspot.com/index.html)
- 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P38
