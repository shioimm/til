# `Omit<T, Keys>`
- オブジェクト型TからプロパティのキーとしてKeysを除くオブジェクト型を返すユーティリティ型
  - T - オブジェクト型
  - Keys - Tのプロパティキー

```ts
type Obj = {
  prop1: 1,
  prop2: "prop",
  prop3: true
}

type OmitObj = Omit<Obj, "prop1" | "prop2">

// type OmitObj = {
//   prop3: true
// } の宣言と同じ
```

## 参照
- [Omit<T, Keys>](https://typescriptbook.jp/reference/type-reuse/utility-types/omit)
