# 非同期処理
- 参照: [非同期処理:コールバック/Promise/Async Function](https://jsprimer.net/basic/async/)

## 性質
- JSにおいて、非同期処理 = 非同期的なタイミングで実行される処理
- JSにおいて、非同期処理は並行処理として扱われる
- JSにおいて、同期処理・非同期処理はいずれもメインスレッドで実行される
  - 非同期処理も同期処理の影響を受ける

## コールバック
- `setTimeout`などを用いて非同期的にコールバック関数を呼び出す

## Promise
- 非同期処理の結果を表現するオブジェクト
  - 非同期処理を統一的なインターフェースで扱うために導入された

```js
// Promiseインスタンスの生成
const promise = new Promise((resolve, reject) => {
  // 非同期の処理が成功したときはresolve()を呼ぶ
  // 非同期の処理が失敗したときにはreject()を呼ぶ
})
const onFulfilled = () => {
  // 成功したときに呼ばれる処理
};
const onRejected = () => {
  // 失敗したときに呼ばれる処理
};

// 成功・失敗時に呼ばれるコールバック関数を登録
promise.then(onFulfilled, onRejected);
```

### 状態
- Promiseインスタンスは、内部的に状態を保つ
  - `Fulfilled` - 成功
  - `Rejected`  - 失敗
  - `Pending`   - 初期状態
- 一度初期状態から状態が変化したインスタンスの状態はそれ以上変化しない
- `then` / `catch`で登録したコールバック関数は、状態が変化した際一回だけ呼び出される

### `then` / `catch`
- Promiseインスタンスの状態が変化した際一回だけ呼ばれるコールバック関数を登録し、
  新しいPromiseインスタンスを作成して返す

### Promiseチェーン
- `then`の返り値であるPromiseインスタンスに対して連続して`then`を呼び出すことができる
- 複数の非同期処理からなる一連の非同期処理を記述するための手法
- `then`に渡したコールバック関数の返り値は次の`then`のコールバック関数へ引数として渡される

## Async Function
- 必ずPromiseインスタンスを返す関数を定義する構文
- 関数の前に`async`をつけることによって定義され、Promiseインスタンスを返す

```js
async function doAsync() {
  return 'Hello'
}
// doAsync()はPromiseインスタンスを返す
doAsync().then(value => {
  console.log(value) // => 'Hello'
})

// -- 以下の処理と同じ ---

function doAsync() {
  return Promise.resolve('Hello');
}
doAsync().then(value => {
  console.log(value); // => 'Hello'
})
```

### Async Functionと通常の関数との違い
- 関数宣言の冒頭に`async`をつける
- Promiseインスタンスを返す
  - Async Functionが値を`return`した場合:       その返り値を持つFulfilledなPromiseインスタンスを返す
  - Async FunctionがPromiseを`return`した場合:  その返り値のPromiseインスタンスを返す
  - Async Function内で例外が発生した場合:       そのエラーを持つRejectedなPromiseインスタンスを返す
- Async Function内で`await`が利用できる

### `await`
- Promiseの非同期処理が完了するまで待つ構文
- 右辺のPromiseインスタンスの状態が変わるまで非同期処理の完了を待つ
- Promiseインスタンスの状態が変わると以降の処理を再開する
- `await`はAsync Functionの中でのみ利用可能

```js
async function doAsync() {
  // 非同期処理
}

async function asyncMain() {
  await doAsync()
  // doAsync()が返すPromiseインスタンスの状態が変わるまで待つ
  // Promiseインスタンスの状態が変わると処理を再開する
}
```

- PromiseインスタンスがRejectedな状態になった場合、`await`はエラーを`throw`する
  - `try...catch` ブロックで`await`式を囲むことによってキャッチできる
