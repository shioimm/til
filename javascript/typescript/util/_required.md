# `Required<Object>`
- オブジェクト型Objectのすべてのプロパティからオプショナルであることを意味する?を取り除くユーティリティ型
  - Object - オブジェクト型

```ts
type Obj = {
  prop1: 1,
  prop2: "prop",
  prop3?: true
}

type RequiredObj = Required<Obj>;

// type RequiredObj = {
//   prop1: 1,
//   prop2: "prop",
//   prop3: true,
// } の宣言と同じ
```

## 参照
- [Required<T>](https://typescriptbook.jp/reference/type-reuse/utility-types/required)
