# enum (列挙型)
```ts
// E列挙型を定義すると、型の名前空間にEnum型、値の名前空間にE値が定義される
enum E { A, B }

let e: E = E.A // E型の列挙型値E.Aを格納する変数eを生成
```

- デフォルトではインデックスと同じ数値が割り当てられる (上書きもできる)

```ts
enum City1 {
  Tokyo,      // 0
  Osaka = 10, // 10
  Fukuoka     // 11
}

let city1: City1  = City1.Fukuoka    // => City型: 11
let city2: City1  = City1['Fukuoka'] // => City型: 11
let city3: string = City1[10]        // => string型: 'Fukuoka'

// 逆引きを禁止する場合
const enum City2 {
  Tokyo,      // 0
  Osaka = 10, // 10
  Fukuoka     // 11
}

let city: string = City2[10] // Error
```

- 文字列値を割り当てることもできる

```ts
enum Color {
  Red   = '#c10000',
  Blue  = '#007ac1',
  Pink  = 0xc10050,
  White = 255
}

let color1: Color  = Color.Red  // Color型: '#c10000'
let color2: string = Color[255] // string型: 'White'
```

```ts
// enumの中に1つでも数値がある場合、不正な値でもenumとみなされる
enum Color1 {
  Red   = '#c10000',
  Blue  = '#007ac1',
  Pink  = 0xc10050,
  White = 255
}

function fn1(arg: Color) {
  return 'ok'
}

fn(Color1.Red)
fn(99999) // エラーにならない

// enumが全て文字列値の場合、指定した値のみがenumとして許可される
enum Color2 {
  Red   = '#c10000',
  Blue  = '#007ac1',
}

function fn2(arg: Color) {
  return 'ok'
}

fn2(Color2.Red)
fn2(Color2.Yellow) // エラー
fn2(99999) // エラー
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
- [definite assignment assertion](https://typescriptbook.jp/reference/values-types-variables/definite-assignment-assertion)
- プログラミングTypeScript
