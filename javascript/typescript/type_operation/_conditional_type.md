# 条件型

```ts
// Tがstringのサブタイプである場合 ? true型 : false型
type IsString<T> = T extends string ? true : false
type T = IsString<string> // true
type F = IsString<number> // false

// TとU共に含まれている型の計算
type Without<T, U> = T extends U ? T : never
type A = Without<boolean | number | string, boolean>          // boolean
type B = Without<boolean | number | string, boolean | number> // boolean | number
```

#### 組み込みの条件型
- `Exclude<T, U>`
- `Extract<T, U>`
- `NonNullable<T>`
- `ReturnType<F>`
- `InstanceType<C>`

## 参照
- プログラミングTypeScript
