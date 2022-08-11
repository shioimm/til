# 配列

```ts
let arr1: string[] = ["str", "ing"]

let arr2: Array<number>
arr2 = [1, 2, 3]

let arr3: (string | number)[]
arr3 = ["str", 1]
```

## タプル

```ts
let arr1: [string, number]
arr1 = ["str", 123] // 順番を守る

let arr2: [string, number?]
arr2 = ["str"]

let arr3: [string, number?][] // let arr3: ([string] | [string, number])[]
arr3 = [["str"], ["ing", 1]]

let arr4: [string, ...number[]]
arr3 = ["str", 1, 2, 3]
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
- [definite assignment assertion](https://typescriptbook.jp/reference/values-types-variables/definite-assignment-assertion)
- プログラミングTypeScript
