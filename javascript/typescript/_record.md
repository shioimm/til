# `Record<Keys, Type>`
- プロパティのキーがKeys、プロパティの値がTypeのオブジェクト型を作るユーティリティ型
  - Keys - string、number、symbol
  - Type - オブジェクトのプロパティの値の型

```ts
type StringNumber = Record<string, number>;
const value: StringNumber = { a: 1, b: 2, c: 3 };

type Person = Record<"firstName" | "middleName" | "lastName", string>;
const person: Person = {
  firstName: "Robert",
  middleName: "Cecil",
  lastName: "Martin",
};
```

## 参照
- [Record<Keys, Type>](https://typescriptbook.jp/reference/type-reuse/utility-types/record)
