# `Omit<Object, Keys>`
- オブジェクト型ObjectからプロパティのキーとしてKeysを除くオブジェクト型を返すユーティリティ型
  - Object - オブジェクト型
  - Keys - Objectのプロパティキー

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
