### useState()

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
