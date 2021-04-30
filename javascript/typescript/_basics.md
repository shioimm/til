# TypeScriptの基礎
### 基本
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
- デフォルト引数を使う場合
```js
// 型の後に = デフォルト値 を渡す
const count = (num: number = 1): void => {
  while (num < 100) {
    console.log(num)
    num++
  }
  console.log('finished')
}

count(10)
```
- 引数に複数の要素を渡す場合(レスト演算子)
```js
// 配列で渡されるのでインデックスを指定できる
const toConcat = (...args: string[]) => `this is ${args[0]} and ${args[1]}.`
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
- 列挙型
- デフォルトではインデックスと同じ数値が割り当てられるが上書きもできる
```js
enum Cities {
  Tokyo,      // 0
  Osaka = 10, // 10
  Fukuoka     // 11
}

let city: Cities = Cities.Fukuoka // => 11
```

### インターフェース
- オブジェクトを引数に受け取る際、プロパティの型を指定することができる
```js
const greet = (person: { name: string }): void => {
  console.log(`Hello ${person.name}.`)
}

const person = {
  name: 'Alice',
  age: 30
}

greet(person)
```

#### interface
- インターフェースプロパティを抽象化する
```js
interface Person {
  name: string
  age?: number // あってもなくても良い場合はプロパティ名に?をつける
  [propName: string]: any // プロパティ名が決まっていない場合は[]を使って要素の型を指定する
  greet(lastName: string): void // メソッドを定義する場合
}

const greet = (person: Person): void => {
  console.log(`Hello ${person.name}.`)
}

const person: Person = { // Personであることを明示する
  name: 'Bob',
  age: 30,
  languages: ['JavaScript', 'Ruby']
  greet(lastName: string) {
    console.log(`Hi, I am ${this.name} ${lastName}.`)
  }
}

greet(person)
person.greet('Marley')
```

- インターフェースを継承する
```js
interface AgedPerson extends Person {
  age: number // ageプロパティを強制する
}

const youngPerson: AgedPerson = {
  name: 'Alice',
  age: 10
}
```

- クラスでインターフェースを使う
```js
class Human implements Person {
  name: string

  constructor(name: string) {
    this.name = name
  }

  greet(lastName: string) {
    console.log(`Hi, I am ${this.name} ${lastName}.`)
  }
}

const newPerson = new Human('Carol')

greet(person)
person.greet('King')
```

- 関数でインターフェースを使う
```js
interface DoubleValues {
  (x: number, y: number): number
}

let doubleFunc: DoubleValues

doubleFunc = (x: number, y: number) => {
  return (x ** y)
}
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)

