# 基本
- 参照: [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- `let`に続けて型を定義
```js
let num: number = 123
let str: string = "string"
let bool: boolean = true
```
- union型として複数の型を定義することもできる
```js
let num: number|string = 123 // "123"でも型エラーにならない
```

### 配列
- 配列の要素の型 + 配列を表す`[]`
```js
let arr: string[] = ["str", "ing"]
```
- 複数の型の要素を配列に含む場合(tuple)
  - 順番を守る必要がある
```js
let arr: [string, number] = ["str", 123]
```

### 関数
- 返り値を型で指定する
```js
const one = (): number => 1
```
- 返り値がない関数の型はvoid
```js
const hoge = (): void => {
  console.log('Hoge')
}
```
- 引数の型も同時に指定できる
```js
const onePlus = (num: number): number => 1 + num
```
- 型としての関数
```js
// funcOnePlusにOnePlusのみを代入できるようになる
let funcOnePlus: (num: number) => number
```

### オブジェクト
- プロパティの型を指定する
```js
let information: {
  data: number[],
  display: (all: boolean) => number[]
} = {
  data: [1, 2, 3],
  display: function(all: boolean): number[] {
    return this.data
  } // 真偽値を渡すと配列を返す関数
}
```

#### type
- オブジェクトのプロパティを抽象化する
```js
type Info = {
  data: number[],
  display: (all: boolean) => number[]
}

let information: Info = {
  data: [1, 2, 3],
  display: function(all: boolean): number[] {
    return this.data
  }
}
```

### enum
```js
enum Cities {
  Tokyo,      // 0
  Osaka = 10, // 10
  Fukuoka     // 11
}

let city: Cities = Cities.Fukuoka // => 11
```
