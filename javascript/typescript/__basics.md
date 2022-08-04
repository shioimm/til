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

type InProgress = { type: "InProgress"; progress: number };
type Success    = { type: "Success" };
type Failure    = { type: "Failure"; error: Error };

type Status     = InProgress | Success | Failure;

const printStatus(status: Status) => {
  switch (status.type) {
    case "InProgress":
      console.log("Uploading");
      break;
    case "Success":
      console.log("Success");
      break;
    case "Failure":
      console.log("Failure");
      break;
    default:
      console.log("Invalid status", status);
  }
}
```

## readonly (読み取り専用プロパティ)

```ts
let obj: {
  readonly prop: number;
};
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
