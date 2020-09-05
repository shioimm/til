# 非同期処理
## Promise
- 参照: [Promiseを使う](https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide/Using_promises)
- 参照: [Promise](https://jsprimer.net/basic/async/#promise)

### TL;DR
- 非同期処理の待機/成功/失敗を示すオブジェクト
  - コールバックを関数に渡すのではなく、関数が返したオブジェクトに対してコールバックを登録する

## Async function
- 参照: [AsyncFunction](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/AsyncFunction)
- 参照: [Async Function](https://jsprimer.net/basic/async/#async-function)

### TL;DR
- Promiseインスタンスを返す関数を定義する構文
  - `async function f () { ...`
- `await` - asyncを用いた関数内で非同期的処理を同期的処理のように扱うための構文
  - `const response = await axios.get('/xxx')`
