# C
## 代入
- 代入はデータのコピーを行う

```c
int a = 1;
int b = a;   // aの値1のコピー
int *c = &a;
int *d = c;  // aのアドレスのコピー

printf("%i\n", a); // 1
printf("%i\n", b); // 1
printf("%p\n", c); // 0x7ffc22dd5d28
printf("%p\n", d); // 0x7ffc22dd5d28
```

## 関数ポインタ
```c
int func(int);

// 関数の返り値の型 (*関数ポインタ変数)(引数の型);
int (*fn)(int);
```

#### 関数ポインタの配列
```c
int func1(int);
int func2(int);

// 各関数の返り値の型(*関数ポインタ変数[])(引数の型)
int (*fns[])(int) = { fn1, fn2 }
```
