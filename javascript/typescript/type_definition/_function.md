# 関数

```ts
// パラメータのアノテートが必要 (返り値は推論可能)
const fn1 = (n: number) => {
}

// 返り値がない関数
const fn2 = (): void => {
  console.log('')
}

// デフォルトパラメータ
const fn3 = (n: number = 1) => {
}

// レストパラメータ
const fn4 = (n: number, ...args: string[]) => {
  // インデックスを指定できる
  // args[0]: string
}

// オプションパラメータ
const fn5 = (n?: number) => {
}
```

#### ジェネレータ関数

```ts
// ジェネレーターが生成する型を明示する
function* countNumber(): Generator<number> {
  let n = 0
  while (1) {
    yield n++
  }
}
let n = countNumber()
n.next() // 0
n.next() // 1
```

## 関数型

```ts
// 関数の型 = 呼び出しシグネチャ
// type Fn = (a: number, b: number) => number
// または
// type Fn = {
//   (a: number, b: number): number
// }

// function fn1(arg: string)
type Fn1 = (arg: string) => string

let fn1: Fn1 = (arg) => {
}

fn1('string')

// function fn2(arg1: string, arg2?: string)
type Fn2 = (arg1: string, arg2?: string) => void

let fn2: Fn2 = (arg1, arg2) => {
}

fn2('str', 'ing')

// function fn3(...numbers: number[]): number
type Fn3 = (...numbers: number[]) => number

let fn3: Fn3 = (numbers) => {
}

fn3([1, 2, 3])

// function fn4(arg1: number, arg2: number | string, arg3?: string): number
type Fn4 = {
  (arg1: number, arg2: number, arg3:string) :number
  (arg1: number, arg2: string) :number
}

let fn4: Fn4 = (
  arg1: number,
  arg2: number | string,
  arg3?: string
) => {
  if (typeof arg2 == 'number' && arg3 !== undefined) {
  } else if (typeof arg2 == 'string') {
  }
}

fn4(1, 2, 'string')
fn4(1, 'string')
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
- [definite assignment assertion](https://typescriptbook.jp/reference/values-types-variables/definite-assignment-assertion)
- プログラミングTypeScript
