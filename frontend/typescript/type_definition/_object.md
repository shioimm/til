# オブジェクト

```ts
// オブジェクトリテラル表記

let obj: {
  nums: number[],
  func: (arg: boolean) => number[]
  [k: number]: boolean // インデックスシグネチャ (動的なキー名)
} = {
  nums: [1, 2, 3],
  func: function(arg: boolean): number[] {
    reuturn this.nums
  },
  1: true
}

// 空のオブジェクトリテラル表記 / Object型
// nullとundefinedを除く全ての型を代入可能
let danger1: {}
let danger2: Object

// object型
// object.propにアクセス不可能
let obj0: object = { prop: 'prop' }
```

```ts
let obj: { prop: string } = { // 型はオブジェクトの形状を表している
  prop: 'prop'
}

class Obj {
  prop: string

  constructor(prop: string) {
    this.prop = prop
  }
}

obj = new Obj('prop0') // OK
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
- [definite assignment assertion](https://typescriptbook.jp/reference/values-types-variables/definite-assignment-assertion)
- プログラミングTypeScript
