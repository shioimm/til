# 関数定義
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

## 参照
- [関数とthis](https://jsprimer.net/basic/function-this/#function-this)
