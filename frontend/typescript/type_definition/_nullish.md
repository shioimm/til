# null, undefined, void, never
- null - 値の欠如
- undefined - 未定義
- void - return文のない関数の返り値
- never - 決して戻ることのない関数の返り値

```ts
let n = null // null

let u // undefined

function v() { // void
  let x = 1 + 2
  let y = x * x
}

function n1() { // never
  throw TypeError('never')
}

function n2(): never { // never
  while (true) {}
}
```

## 参照
- プログラミングTypeScript
