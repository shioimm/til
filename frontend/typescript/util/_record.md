# `Record<Key, Value>`
- プロパティのキーがKey、プロパティの値がValueのオブジェクト型を作るユーティリティ型
  - Key - string、number、symbol
  - Value - オブジェクトのプロパティの値の型

```ts
type StringNumber = Record<string, number>;

const value: StringNumber = { a: 1, b: 2, c: 3 };
```

```ts
type Person = Record<"firstName" | "middleName" | "lastName", string>;

const person: Person = {
  firstName:  "Robert",
  middleName: "Cecil",
  lastName:   "Martin",
};
```

### `Record<K, T>`を用いたインデックス型

```ts
// 同じ
let obj1: { [K: string]: number };
let obj2: Record<string, number>;
```

## 参照
- [Record<Keys, Type>](https://typescriptbook.jp/reference/type-reuse/utility-types/record)
