# ジェネリクス
- 型を変数として扱うための構文

```ts
function fn<T>(arg: T): T { // 慣習として型変数名にTを用いる
  return arg;
}

fn<string>("str");
fn<number>(1);
```

```ts
// 型引数Tを特定の型HTMLElementに限定する

function changeBackgroundColor<T extends HTMLElement>(element: T) {
  element.style.backgroundColor = "red"; // elementは必ずHTMLElementまたはそのサブタイプ
  return element;
}
```

## 参照
- [ジェネリクス (generics)](https://typescriptbook.jp/reference/generics)
- [型引数の制約](https://typescriptbook.jp/reference/generics/type-parameter-constraint)
