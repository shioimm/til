# `Extract<T, U>`
- ユニオン型TからUのみを含むユニオン型を返すユーティリティ型
  - T - ユニオン型
  - U - Tから抽出したい型

```ts
type Union = "A" | "B" | "C" | "D" | "E";

type ExtractUnion = Extract<Union, "D" | "E">;
// type ExtractUnion = "D" | "E"; の宣言と同じ
```

## 参照
- [Extract<T, U>](https://typescriptbook.jp/reference/type-reuse/utility-types/extract)
