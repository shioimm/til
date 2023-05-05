# #if defined / #if !defined / #ifdef / #ifndef
- 定義ありの確認

```c
// 識別子が定義されている場合
#if defined 識別子
  // 処理
#endif

#ifdef 識別子
  // 処理
#endif

// 定義されていない場合
#if !defined 識別子
  // 処理
#endif

#ufndef 識別子
  // 処理
#endif
```
