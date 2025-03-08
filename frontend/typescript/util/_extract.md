# `Extract<T, U>`
- Tに含まれている型のうちUに割り当てられる型のみを抽出するユーティリティ型
  - T - 元の型
  - U - Tから抽出したい型

```ts
type Union = "A" | "B" | "C" | "D" | "E";

type ExtractUnion = Extract<Union, "D" | "E">;
// type ExtractUnion = "D" | "E"; の宣言と同じ
```

## 参照
- [Extract<T, U>](https://typescriptbook.jp/reference/type-reuse/utility-types/extract)
