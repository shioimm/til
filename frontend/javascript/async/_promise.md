# Promise
- 非同期処理の結果を表現するビルトインオブジェクト

```js
// Promiseインスタンスを作成
const promise = new Promise((resolve, reject) => {
  resolve() // 非同期の処理が成功した場合の処理
  reject()  // 非同期の処理が失敗した場合の処理
});

const onResolved = () => {
  console.log("successed");
};

const onRejected = () => {
  console.log("failed");
};

// 成功時 / 失敗時に呼ばれるコールバック関数を登録
promise.then(onResolved, onRejected);
```

```js
const fetch = (bool) => {
  return new Promise((resolve, reject) => {
    if (bool) {
      // 処理に成功した場合
      resolve("successed");
    } else {
      // 処理に失敗した場合
      reject(new Error("failed")); // 失敗時はErrorオブジェクトが返されるためcatchできる
    }
  });
}

fetch(<BOOLEAN>).then((result) => {
  console.log(result); // => successed
}).catch((error) => {
  console.log(error)   // => failed
});
```

### Promiseインスタンスの内部状態
- Fulfilled - 成功 (resolve関数が呼ばれる)
- Rejected  - 失敗 (reject関数が呼ばれる)
- Pending   - 初期状態 (Promiseインスタンスを作成した状態)

#### 状態変化
- インスタンスは初期状態から一回のみ状態変化する
- `then` / `catch`はPromiseインスタンスが初期状態から変化する際の一回だけ呼ばれるコールバック関数を登録し、
  新しいPromiseインスタンスを作成して返す

## 例外処理
- 例外が発生したPromiseインスタンスはreject関数を呼び出したのと同じように失敗したものとして扱われる

```js
const throwError = () => {
  return new Promise((_, _) => {
    throw new Error("throw error"):
  });
}

throwError().catch(error => {
  console.log(error.message); // => "throw error"
});

```

## Promiseチェーン
- `then`の返り値であるPromiseインスタンスに対して連続して`then`を呼び出すことができる
- `then`のコールバック関数の返り値が次の`then`のコールバック関数へ引数として渡される

```js
function fn() {
  return new Promise((resolve, reject) => {
    setTimeout(() => resolve(1), 10);
  });
}

function fnMain() {
  return fn()
}).then(result => {
  console.log(result); // 1
  return result + 1;
}).then(result => {
  console.log(result); // 2
  return result + 1;
}).catch(error => {
  console.log("failed");
}).finally(result => { // finally: ES2018
  console.log(result);
});
```

## その他のAPI
- `Promise.resolve` - FulfilledなPromiseインスタンスを作成
- `Promise.reject` - RejectedなPromiseインスタンスを作成
- `Promise.all` - 複数のPromiseを使った非同期処理をひとつのPromiseとして実行 (全て実行)
- `Promise.race` - 複数のPromiseを使った非同期処理をひとつのPromiseとして実行 (最低1つ実行)

## 参照
- [[ES2015] Promise](https://jsprimer.net/basic/async/#promise)
