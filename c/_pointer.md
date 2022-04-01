# ポインタ操作
## 機能
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

#### 記号
- アドレス演算子 `&`
  - 変数のアドレスを求める演算子
- 間接参照演算子 `*`
 - ポインタ変数の指すアドレスに格納された値を扱う
- ポインタ変数宣言 `*`
  - 変数をポインタ型で初期化する
  - e.g. `int *p` - int型のデータを格納するメモリ領域の先頭アドレスを格納するポインタ型の変数p
- `[i]`
  - `アドレス + (型のバイト数 * i)` の位置を示す

#### 引数としてのポインタ
```c
#include <stdio.h>

void func(int* pvalue);

void func(int* pvalue) {
  *pvalue = 100; // 引数の値が指すアドレスに100を格納
  return;
}

int main(void) {
  int value = 10;
  func(&value);          // アドレスの値を渡す
  printf("%d\n", value); // 10ではなく100を表示
  return 0;
}
```

#### 配列
```c
#include <stdio.h>

int main(void) {
  int array[10];
  printf("array    (%p)\n", array);     // array    (0x7ffee7dbb770) 先頭アドレス
  printf("array[0] (%p)\n", &array[0]); // array[0] (0x7ffee7dbb770) 先頭アドレス
  printf("array[1] (%p)\n", &array[1]); // array[1] (0x7ffeea846774) 先頭アドレス + 4バイト (int型)
  return 0;
}
```

```c
#include <stdio.h>

int getavg(int data[10]);

int main(void) {
  int avg, array[3] = { 10, 20, 30 };
  avg = getavg(array);
  printf("%d\n", avg); // 20
  return 0;
}

int getavg(int array[], int denominator) { // 配列の先頭アドレスを受け取る
  int i, avg = 0;
  for (i = 0; i < 10; i++) {
    avg += array[i]; // 配列の先頭アドレス + (4バイト * i) の位置にアクセス
  }
  return avg / denominator;
}
```

### ポインタの間違い
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
