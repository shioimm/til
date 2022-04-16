# volatile
- コンパイラによる最適化を抑止する

```c
int main(void)
{
  volatile int i = 0;

  while (i == 0) {} // volatileがない場合 while(1) に最適化される

  return 0;
}
```
