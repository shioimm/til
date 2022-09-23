# 条件型

```ts
// Tがstringのサブタイプである場合 ? true型 : false型
type IsString<T> = T extends string ? true : false
type T = IsString<string> // true
type F = IsString<number> // false
```

#### 分配条件型

```ts
(T1 | T2) extends T ? A : B // => (T1 extends T ? A : B) | (T2 extends T ? A : B)

type Without<T, U> = T extends U ? T : never
type A = Without<boolean | number | string, boolean>          // boolean
type B = Without<boolean | number | string, boolean | number> // boolean | number
```

#### inferキーワード
- 型をキャプチャする

```ts
type Type<T> = T extends (infer U)[] ? U : any

type A = Type<number[]> // number
type B = Type<string>   // any
```

#### 組み込みの条件型
- `Exclude<T, U>`
- `Extract<T, U>`
- `NonNullable<T>`
- `ReturnType<F>`
- `InstanceType<C>`

## 参照
- プログラミングTypeScript 6.5
