# `Exclude<T, U>`
- ユニオン型TからUを除くユニオン型を返すユーティリティ型
  - T - ユニオン型
  - U - Tから除きたい型

```ts
type Union = "A" | "B" | "C" | "D" | "E";

type ExtractUnion = Exclude<Union, "D" | "E">;
// type ExtractUnion = "A" | "B" | "C"; の宣言と同じ
```

## 参照
- [Exclude<T, U>](https://typescriptbook.jp/reference/type-reuse/utility-types/exclude)
