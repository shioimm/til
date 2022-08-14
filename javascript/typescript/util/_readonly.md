# `ReadOnly<Object>`
- オブジェクト型Objectのすべてのプロパティを読み取り専用にするユーティリティ型
  - Object - オブジェクト型

```ts
type Obj = {
  prop1: 1,
  prop2: "prop",
  prop3?: true
}

type ReadOnlyObj = ReadOnly<Obj>;

// type ReadOnlyObj = {
//   readonly prop1: 1,
//   readonly prop2: "prop",
//   readonly prop3?: true,
// } の宣言と同じ
```

## 参照
- [Required<T, U>](https://typescriptbook.jp/reference/type-reuse/utility-types/required)
