# 関数

```js
const fn = (): number => {
}

// 返り値がない関数
const fn = (): void => {
  console.log('')
}

// 引数の型
const fn = (num: number): number => {
}

// デフォルト引数
// 型の後に = デフォルト値 を渡す
const fn = (n: number = 1): void => {
}

// 引数に複数の要素を渡す場合(レスト演算子)
// 配列で渡されるのでインデックスを指定できる
const fn = (...args: string[]) => {
  // args[0]: string
  // args[1]: string...
}
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
- [definite assignment assertion](https://typescriptbook.jp/reference/values-types-variables/definite-assignment-assertion)
- プログラミングTypeScript
