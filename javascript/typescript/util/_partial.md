# `Partial<Object>`
- オブジェクト型Objectののすべてのプロパティをオプションプロパティにするユーティリティ型
  - Object - オブジェクト型

```ts
type Obj = {
  prop1: 1,
  prop2: "prop",
  prop3?: true
}

type PartialObj = Partial<Obj>;

// type PartialObj = {
//   prop1?: 1,
//   prop2?: "prop",
//   prop3?: true,
// } の宣言と同じ
```

## 参照
- [Partial<T>](https://typescriptbook.jp/reference/type-reuse/utility-types/partial)
