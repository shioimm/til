# interface
- インターフェースプロパティの抽象化

```js
interface Obj {
  prop1: string
  prop2?: number
  [K: string]: string // インデックス型: プロパティ名が決まっていない場合 (キー名はstring、number、symbol)
  fn(arg: string): void
}

const fn = (obj: Obj): void => {
  console.log(`${person.prop1}`)
}

const obj: Obj = {
  prop1: 'abc',
  prop2: 100,
  prop3: 'JavaScript',
  fn(arg: string) {
    console.log(`${this.prop1} ${arg}`)
  }
}

fn(obj)
obj.fn('def')
```

## 継承
```ts
interface extentedObj extends Obj {
  prop2: number // prop2プロパティを強制
}

const objHasProp2: extentedObj = {
  name: 'abc',
  age: 99
}
```

## クラス

```ts
class KlassObj implements Obj {
  constructor(prop: string) {
    this.prop = prop
  }

  fn(arg: string) {
    console.log(`${this.prop} ${arg}`)
  }
}

const newObj = new KlassObj('abc')

newObj.fn('def')
```

## 関数

```ts
interface DoubleValues {
  (x: number, y: number): number
}

let doubleFn: DoubleValues = (x: number, y: number) => {
  return (x ** y)
}
```
