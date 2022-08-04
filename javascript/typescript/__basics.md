# 型定義

```ts
let num: number = 123
let str: string = "string"
let bool: boolean = true
```

### 配列

```ts
let arr1: string[] = ["str", "ing"]

let arr2: Array<number>
arr2 = [1, 2, 3]

// 複数の型の要素を配列に含む場合(tuple)
let arr3: [string, number] = ["str", 123] // 順番を守る
```

### 関数
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

### オブジェクト

```ts
let obj: {
  nums: number[],
  func: (arg: boolean) => number[]
} = {
  nums: [1, 2, 3],
  func: function(arg: boolean): number[] {
    reuturn this.nums
  }
}
```

### enum
- デフォルトではインデックスと同じ数値が割り当てられるが上書きもできる

```js
enum Cities {
  Tokyo,      // 0
  Osaka = 10, // 10
  Fukuoka     // 11
}

let city: Cities = Cities.Fukuoka // => 11
```

### union

```ts
let numOrStr: number|string = 123

// 配列
let arr: (string | number)[] = [1, 2, 3]
```

#### 判別可能なユニオン型
- オブジェクト型で構成されたユニオン型
  - 各オブジェクトの型を判別するためのdiscriminatorプロパティを持つ
  - discriminatorの型はリテラル型などであること
  - 各オブジェクト型は固有のプロパティを持つことができる

```ts
// discriminator = type

type Success = { type: "Success" };
type Failure = { type: "Failure"; error: Error };
type Status  = Success | Failure;

const printStatus(status: Status) => {
  if (status.type == "Success") {
    console.log("Success");
  } else if (status.type == "Failure")
    console.log("Failure");
  } else {
    console.log("Invalid status", status);
  }
}
```

### インターセクション型

```ts
type X = {
  x: number;
};

type Y = {
  y: number;
};

type XZndY = X & Z;

const n: XZndY = {
  x: 0,
  y: 1,
};
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
