### useState()

- stateと、stateを更新するfunction
- Using the State Hook from https://reactjs.org/docs/hooks-state.html

```javascript
import * as React from 'react';

function Example() {
  // state.countを表すcountと、countを更新するsetCountを定義
  // 引数0は初期値
  const [count, setCount] = React.useState(0);

  return (
    <div>
      <p>You clicked {count} times</p>
      // クリック毎にstate.count + 1
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}
```

### useCallback()

- メモ化されたコールバック
- 更新されるstateのみ再計算・再生成を行う

```javascript
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
- Hooks API Reference from https://reactjs.org/docs/hooks-reference.html#usecallback

```javascript
const memoizedCallback = useCallback(
  () => {
    doSomething(a, b);
  },
  [a, b],
);
```
