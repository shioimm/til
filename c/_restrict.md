# restrict修飾子 (C99)
- 複数のポインタが同一のオブジェクトを指していない
  - ポインタ型に対してのみ適用可能
  - コンパイラに対する最適化のヒントとして明示する

```c
char *strcpy(char *restrict s1, const char *restrict s2);
```

## 参照
- 新・C言語入門 シニア編 P478
