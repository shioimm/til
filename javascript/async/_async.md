# Async Function
- 必ずPromiseインスタンスを返す関数を定義するための構文
  - Async Functionが値を`return`した場合 - その返り値を持つFulfilledなPromiseインスタンスを返す
  - Async FunctionがPromiseを`return`した場合 -  その返り値のPromiseインスタンスを返す
  - Async Function内で例外が発生した場合 - そのエラーを持つRejectedなPromiseインスタンスを返す

```js
async function doAsync() { // Promiseインスタンスを返す
  return 'Do async'
}

doAsync().then(value => {
  console.log(value) // => "Do async"
});

// asyncを使用しない場合

function doAsync() {
  return Promise.resolve("Do async");
}

doAsync().then(value => {
  console.log(value); // => 'Do async'
})
```

```js
// resolved
async function resolveFn() {
  return "resolved";
}

resolveFn().then(value => {
  console.log(value); // => "resoled"
});

// rejected
async function rejectFn() {
  return Promise.reject(new Error("failed"));
}

rejectFn().catch(error => {
  console.log(error.message); // => "failed"
});

// throw error
async function errorFn() {
  throw new Error("throw error");
}

errorFn().catch(error => {
  console.log(error.message); // => "throw error"
});
```

## Async Functionの定義
```
async function fn1() {
}
const fn2 = async function() {
};
const fn3 = async() => {
};
const obj = {
  async method() {
  }
};
```

#### Async Functionと通常の関数との違い
- 関数宣言の冒頭に`async`をつける
- Promiseインスタンスを返す
- Async Function内で`await`が利用できる

## `await`
- Promiseインスタンスの状態が変わるまで非同期処理の完了を待つ
- Promiseインスタンスの状態が変わると処理を再開する

```js
async function doAsync() {
  // 非同期処理
}

async function asyncMain() {
  // doAsync()が返すPromiseインスタンスの状態が変わるまで待つ
  await doAsync()
  // Promiseインスタンスの状態が変わると処理を再開する
}
```

- 状態変化を待つ対象のPromiseインスタンスの評価結果を返す

```js
async function asyncMain() {
  const value = await Promise.resolve("resolved");
  console.log(value); // => "resolved"
}

asyncMain(); // Promiseインスタンスを返す

// asyncを使用しない場合

function asyncMain() {
  return Promise.resolve("resolved").then(value => {
    console.log(value); // => "resolved"
  });
}

asyncMain(); // Promiseインスタンスを返す
```

- PromiseインスタンスがRejectedな状態になった場合、`await`はエラーを`throw`する

```js
async function asyncMain() {
  const value = await Promise.reject(new Error("throw error"));
}

asyncMain().catch(error => {
  console.log(error.message); // => "throw error"
});

// try...catchも可能
async function asyncMain() {
  try {
    const value = await Promise.reject(new Error("throw error"));
  } catch (error) {
    console.log(error.message); // => "throw error"
  }
}
```

```js
const fetch = async (bool) => {
  return await new Promise((resolve, reject) => {
    if (bool) {
      // 処理に成功した場合
      resolve("successed");
    } else {
      // 処理に失敗した場合
      reject(new Error("failed")); // 失敗時はErrorオブジェクトが返されるためcatchできる
    }
  });
}

const main = async () => {
  try {
    const result = await fetch(<BOOLEAN>);
    console.log(result); // => successed
  } catch(error) {
    console.log(error)   // => failed
  };
};

main();
```

#### Promiseチェーン

```js
function fn() {
  return new Promise((resolve, reject) => {
    setTimeout(() => resolve(1), 10);
  });
}

async function fnMain() {
  let result = 0;
  result = await fn();
  result++;
});

fnMain().then(result => {
  console.log(result); // 2
});
```

#### 並列処理

```js
function fn(bool) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (bool) {
        resolve("resolved");
      } else {
        reject(new Error("rejected"));
      }
    }, 10);
  });
}

async function execFnAll(bools) {
  const promises = bools.map(function(bool) {
    return fn(bool);
  });

  const results = await Promise.all(promises);

  return results.map(result => {
    return result;
  });
}

execFnAll([true, true, false]).then((results) => {
  console.log(results); // => ["resolved", "resolved", "rejected"] (順不同)
});
```

## 参照
- [[ES2017] Async Function](https://jsprimer.net/basic/async/#async-function)
