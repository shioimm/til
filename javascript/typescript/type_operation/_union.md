# 合併型

```ts
let numOrStr: number|string = 123

// 配列
let arr: (string | number)[] = [1, 2, 3]

// 複数の型の値を返しうる関数
function fn(n: number): number | string {
  if (n == 0) {
    return "zero";
  }
  return n;
}
```

#### 判別可能なユニオン型
- オブジェクト型で構成されたユニオン型
  - 各オブジェクトの型を判別するためのdiscriminatorプロパティを持つ
  - discriminatorの型はリテラル型などであること
  - 各オブジェクト型は固有のプロパティを持つことができる

```ts
// discriminator = type

type Success = { type: "Success" };
type Failure = { type: "Failure"; error: Error };
type Status  = Success | Failure;

const printStatus(status: Status) => {
  if (status.type == "Success") {
    console.log("Success");
  } else if (status.type == "Failure")
    console.log("Failure");
  } else {
    console.log("Invalid status", status);
  }
}
```

## 参照
- [TypeScript基礎講座](https://www.udemy.com/course/typescript-y/)
- [判別可能なユニオン型](https://typescriptbook.jp/reference/values-types-variables/discriminated-union)
- [definite assignment assertion](https://typescriptbook.jp/reference/values-types-variables/definite-assignment-assertion)
- プログラミングTypeScript
