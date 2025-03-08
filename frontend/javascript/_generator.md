# ジェネレータ
- 反復可能なイテレータオブジェクト
  - Symbol.iteratorプロパティを持っており (反復可能オブジェクト) 、
    nextメソッドが定義されている (イテレータオブジェクト)
- 処理を抜け出したり後から復帰したりすることができる
  - Generator関数の中でyieldキーワードを呼ぶと、yieldは一度その値を呼び出し元へ返却し、
    次に呼ばれたときはその続きから処理を再開する

```js
function* fn(i) {
  yield i;
  yield i + i;
}

const gen = fn(1); // [object Generator]
console.log(gen.next().value); // 1
console.log(gen.next().value); // 2
```

```js
// Generatorオブジェクトを返すジェネレーター関数の定義

function* fn1() {
  // ...
}

const fn2 = function* () {
  // ...
};

class Klass {
  public *fn3() {
    // ...
  }
}
```

## 参照
- [ジェネレーター (generator)](https://typescriptbook.jp/reference/advanced-topics/generator)
- [`function* 宣言`](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Statements/function*)
