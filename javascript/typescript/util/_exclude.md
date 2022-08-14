# `Exclude<T, U>`
- Tに含まれている型からUを除くユーティリティ型
  - T - 元の型
  - U - Tから除きたい型

```ts
type Union = "A" | "B" | "C" | "D" | "E";

type ExcludeUnion = Exclude<Union, "D" | "E">;
// type ExcludeUnion = "A" | "B" | "C"; の宣言と同じ
```

## 参照
- [Exclude<T, U>](https://typescriptbook.jp/reference/type-reuse/utility-types/exclude)
