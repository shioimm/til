# ジェネリクス構文
- 型を変数として扱うための構文
  - ジェネリック型パラメータ - 複数の場所で型レベルの制約を強制するために使われるプレースホルダの型

```ts
function fn<T>(arg: T): T { // 慣習として型変数名にTを用いる
  return arg;
}

fn<string>("str");
fn<number>(1);
```

#### ジェネリック型パラメータを用いてtypeを定義する場合

```ts
type Filter = <T>(array: T[], fn: (item: T) => boolean): T[]

let filter: Filter = (array, fn) => {
  let result = []
  for (let i = 0; i < array.length; i++) {
    let item = array[i]
    if (fn(item)) {
      result.push(item)
    }
   }
  return result
}

filter([1, 2, 3, 4], n => n < 3)
// 明示的なアノテートも可能
filter<number, boolean>([1, 2, 3, 4], n => n < 3)
```

#### 複数の型が必要な場合

```ts
type Map = <T, U>(array: T[], fn: (item: T) => U): U[]

let map: Map = (array, fn) => {
  let result = []
  for (let i = 0; i < array.length; i++) {
    result[i] = fn(array[i])
  }
  return result
}

map<number, number>([1, 2, 3], n => n + n)
```

#### 型に上限を設ける場合

```ts
// TをHTMLElementかHTMLElementのサブタイプに限定する

type ChangeBackgroundColor = {
  <T extends HTMLElement>(element: T) => T
}

let changeBackgroundColor: ChangeBackgroundColor = (element) => {
  element.style.backgroundColor = "red";
  return element;
}

changeBackgroundColor(HTMLElement)
```

#### 型に複数の上限を設ける場合

```ts
type Height = { hightLength: number }
type Width  = { widthLength: number }

function calcArea <Shape extends Height & Width>(s: Shape): number {
  return s.hightLength * s.widthLength
}

type Square = Height & Width
let square: Square = { hightLength: 4, widthLength: 3 }
calcArea(square)
```

#### 型にデフォルト値を設定する場合

```ts
type ChangeBackgroundColor = {
  <T extends HTMLElement = HTMLElement>(element: T) => T
}
```

## 参照
- [ジェネリクス (generics)](https://typescriptbook.jp/reference/generics)
- [型引数の制約](https://typescriptbook.jp/reference/generics/type-parameter-constraint)
- プログラミングTypeScript
