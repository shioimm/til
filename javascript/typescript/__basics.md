# 型定義
```ts
let num: number = 123
let str: string = "string"
let bool: boolean = true

// union型 (複数の型定義)
let num: number|string = 123 // "123"でも型エラーにならない
```

### 配列
```ts
let arr: string[] = ["str", "ing"]

// 複数の型の要素を配列に含む場合(tuple)s
let arr: [string, number] = ["str", 123] // 順番を守る
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

## readonly (読み取り専用プロパティ)

```ts
let obj: {
  readonly prop: number;
};
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)

