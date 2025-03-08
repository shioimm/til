# 交差型

```ts
type X = {
  x: number;
};

type Y = {
  y: number;
};

type XZndY = X & Z;

const n: XZndY = {
  x: 0,
  y: 1,
};
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
- [definite assignment assertion](https://typescriptbook.jp/reference/values-types-variables/definite-assignment-assertion)
- プログラミングTypeScript
