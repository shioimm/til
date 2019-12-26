# `useCallback`
- メモ化されたコールバック
- 更新されるstateのみ再計算・再生成を行う
```js
import * as React from "react";

function Example () {
  const [count, setCount] = useState(0);

  const handleClick = useCallback(() => {
    // デフォルトでprevに0が入り、+ 1でインクリメントしている
    setCount(prev => prev + 1);
  }, []);

  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={handleClick}>
        Click me
      </button>
    </div>
  );
}
```

- 配列にはコールバックが依存している値を渡す
- 参照: [Hooks API Reference](https://reactjs.org/docs/hooks-reference.html#usecallback)

```js
const memoizedCallback = useCallback(
  () => {
    doSomething(a, b);
  },
  [a, b],
);
```
