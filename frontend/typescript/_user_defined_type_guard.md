# ユーザー定義型ガード (user-defined type guard)
- (前提) 型の絞り込みはスコープ内でのみ有効
- is演算子 - 型の絞り込みを呼び出し側に引き継がせる

```ts
function isString(a: unknown): a is string {
  return typeof a === 'string'
}

function parseInput(input: string | number) {
  let formattedInput: string
    if (isString(input)) {
      formattedInput = input.toUpperCase()
    }
}

// isString()の返り値をa is stringではなくbooleanにすると
// parseInput()の定義時に以下のエラーが表示される
//   Property 'toUpperCase' does not exist on type 'string | number'.
//   Property 'toUpperCase' does not exist on type 'number'
```

## 参照
- プログラミングTypeScript 6.4.2
