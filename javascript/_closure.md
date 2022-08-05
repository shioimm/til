# クロージャ
### 言語特性
- JSはどこからも参照されなくなったデータをGCする
- JSは静的スコープによりコードの実行前にどの識別子がどの変数を参照するかを静的に決定する

```js
const x = 10;

function printX() {
  return x; // グローバルスコープでの変数定義const x = 10;を参照することが静的に決定する
}

function runPrintX() {
  const x = 20; // runPrintX関数スコープ内での変数定義 (printX関数内から参照されない)
  printX();
}

run(); // => 10
```

### クロージャ

```js
const createCounter = () => {
  let count = 0;
  return function increment() {
    count = count + 1;
    return count;
  };
};

const myCounter = createCounter();
myCounter(); // => 1
myCounter(); // => 2

// 1. (静的スコープ) increment関数はcreateCounter関数スコープ内での変数定義let count = 0;を参照
// 2. (GC) createCounter関数がincrement関数を参照
// 3. (GC) myCounter関数がcreateCounter関数を参照
```

## 参照
- [関数とスコープ](https://jsprimer.net/basic/function-scope/#function-and-scope)
