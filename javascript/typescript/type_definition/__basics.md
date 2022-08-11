# 型定義

```ts
let num: number = 123
let str: string = "string"
let bool: boolean = true

// 分割代入引数
function foo({ a, b }: { a: number; b: number }) {
}
function bar([num1]: number[]) {
}
```

## readonly (読み取り専用プロパティ)

```ts
let obj: {
  readonly prop: number;
};
```

## constアサーション (読み取り専用オブジェクト)

```ts
const obj: {
  prop: number;
} as const;
```

- ネストしたオブジェクトも再帰的にreadonlyにすることができる

## definite assignment assertion
- 変数が初期化済みであることを明示する

```ts
let num!: number;
initNum();

console.log(num);

function initNum() {
  num = 2;
}
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
- [definite assignment assertion](https://typescriptbook.jp/reference/values-types-variables/definite-assignment-assertion)
- プログラミングTypeScript
