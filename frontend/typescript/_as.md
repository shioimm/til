# 型アサーション
- 型推論を上書きする
  - 型の変換は行わず、コンパイラに型の情報を伝える

```ts
const value: string | number = "string";
const strLength: number = (value as string).length;
```

## 参照
- [型アサーション](https://typescriptbook.jp/reference/values-types-variables/type-assertion-as)
