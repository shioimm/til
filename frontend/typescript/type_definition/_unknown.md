# unknown型
- どんな値でも代入可能な型
- unknown型の値は具体的な型への代入およびプロパティへのアクセス、メソッドの呼び出しが不可能
  - `typeof`によって型を絞り込んだ場合は以降その型にキャストされる

```
let a: unknown = 30 // unknown
let b = a + 10 // Error

if (typeof a === 'number') {
  typeof a // number
}

typeof a //number
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
- [definite assignment assertion](https://typescriptbook.jp/reference/values-types-variables/definite-assignment-assertion)
- プログラミングTypeScript
