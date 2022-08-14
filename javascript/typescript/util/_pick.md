# `Pick<Object, Keys>`
- オブジェクト型ObjectからプロパティのキーとしてKeysのみを含むオブジェクト型を作るユーティリティ型
  - Object - オブジェクト型
  - Keys - Tのプロパティキー

```ts
type Obj = {
  prop1: 1,
  prop2: "prop",
  prop3: true
}

type PickObj = Pick<Obj, "prop1" | "prop2">

// type PickObj = {
//   prop1: 1,
//   prop2: "prop",
// } の宣言と同じ
```

## 参照
- [Pick<T, Keys>](https://typescriptbook.jp/reference/type-reuse/utility-types/pick)
