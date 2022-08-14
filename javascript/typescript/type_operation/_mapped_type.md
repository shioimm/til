# Mapped Type

```ts
type T = {
  prop1: number
  prop2: boolean
  prop3: string[]
}

let t: T = {
  prop1: 1,
  prop2: true,
  prop3: ['string']
}

// すべてのフィールドを省略可能にする
type OptionalT = {
  [K in keyof T]?: T[K]
}

// すべてのフィールドをnull許容にする
type NullableT = {
  [K in keyof T]: T[K] | null
}

// すべてのフィールドを読み取り専用にする
type ReadOnlyT = {
  readonly [K in keyof T]: T[K]
}
```

#### 組み込みのMapped Type
- `Partial<Object>`
- `Pick<Object, Keys>`
- `ReadOnly<Object>`
- `Record<Key, Value>`
- `Required<Object>`

## 参照
- プログラミングTypeScript
