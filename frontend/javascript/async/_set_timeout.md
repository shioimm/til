# `setTimeout`
- `delay`ミリ秒後にコールバック関数を呼び出す (メッセージキューに戻す)
- ノンブロッキングで動作する

```js
setTimeout(コールバック関数, delay);
```

```js
console.log("1");

setTimeout(() => {
  console.log("3");
}, 10);

console.log("2");

// 1
// 2
// 3
```

## 例外処理
- 非同期処理の外からは非同期処理の中で発生した例外を捕捉できない
- コールバック関数内でエラーを捕捉する必要がある

```js
setTimeout(() => {
  try {
    throw new Error("in setTimeout");
  } catch (error) {
    console.log("reached");
  }
}, 10);

console.log("reached");
```

### エラーファーストコールバック
- `setTimeout`などを利用した非同期処理中に発生した例外を扱うためのルール
  - 処理に成功した場合、コールバック関数の1番目の引数にnull、2番目以降の引数に成功時の結果を渡して呼び出す
  - 処理に失敗した場合、コールバック関数の1番目の引数にエラーオブジェクトを渡して呼び出す

```js
const fetch = (bool, callback) => {
  setTimeout(() => {
    if (bool) {
      // 処理に成功した場合
      callback(null, "successed");
    } else {
      // 処理に失敗した場合
      callback(new Error("failed"));
    }
  }, 1000);
}

// 処理に成功する場合
fetch(true, (error, result) => {
  if (error) {
    // unreached
  } else {
    console.log(result); // => "successed"
  }
});

// 処理に失敗する場合
fetch(false, (error, result) => {
  if (error) {
    console.log(error.message); // => "failed"
  } else {
    // unreached
  }
});
```

## 参照
- [非同期処理](https://jsprimer.net/basic/async/#async-processing)
