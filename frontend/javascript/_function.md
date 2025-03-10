# 関数
## 関数定義
### function文 (関数宣言)
- 巻き上げが発生する
- `this`の内容は動的に決まる
- 引数名が重複しても構文エラーにならない
- 関数名が重複しても構文エラーにならない

```js
function fn() {
}

fn();
```

### function式 (関数式)
- `this`の内容は動的に決まる
- 引数名が重複しても構文エラーにならない
- 関数名の代わりに変数名を使用する

```js
const fn = function() {
};

fn();
```

### Arrow Function (関数式)
- `this`の内容はレキシカルスコープで静的に決まる
- arguments変数がない
- ジェネレーター構文をサポートしていない
- 関数名の代わりに変数名を使用する

```js
const fn = () => {
};

fn();
```

### メソッド定義

```js
const obj = {
  method1 () {
  },
  method2: () => {
  }
};

obj.method();
```

## 関数呼び出し

```js
function add(a, b) {
  return a + b
}

add(10, 20)

// 値nullを関数内のthisにバインドし、[10, 20]を関数の引数として展開して関数を実行
add.apply(null, [10, 20])

// 値nullを関数内のthisにバインドし、10, 20を関数の引数として展開して関数を実行
add.call(null, 10, 20)

// 値nullを関数内のthisにバインドし、10, 20を関数の引数として展開 -> 関数を実行
add.bind(null, 10, 20)()
```

## `this`

```js
// JSではthisはメソッドの呼び出し時、ドット(.)の左側にあるものの値を取る
function ppDate() {
  console.log(`${this.getMonth() + 1} / ${this.getDate()}`)
}

ppDate3(new Date)

// TSでは関数の最初のパラメータとしてthisの型を指定する
function ppDate(this: Date) {
  console.log(`${this.getMonth() + 1} / ${this.getDate()}`)
}

ppDate2(new Date)
```

## 参照
- [関数とthis](https://jsprimer.net/basic/function-this/#function-this)
- プログラミングTypeScript
