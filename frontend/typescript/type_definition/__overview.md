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

## constアサーション
- 型の拡大を抑制する
- 読み取り専用オブジェクトにする
  - ネストしたオブジェクトも再帰的にreadonlyにすることができる

```ts
let obj1 = { prop: 1 } as const;      // obj1に{ readonly prop: 1 }型が割り当てられる
let obj2 = [1, { prop: 1 }] as const; // obj2にreadonly [1, { readonly prop: 1 }]型が割り当てられる
```

#### 型の拡大
- `let`で宣言する変数にリテラル値を代入する際、明示的に型をアノテーションしないと
  変数の型はリテラル型ではなくそのリテラルが属するベースの型へと拡大される現象

```ts
let   letA        = 'str' // letA:   string
let   letB: 'str' = 'str' // letB:   'str'
const constA      = 'str' // constA: 'str'
```

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
