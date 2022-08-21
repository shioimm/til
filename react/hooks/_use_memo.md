# `useMemo`
- 親コンポーネントの再描画時、自コンポーネントのpropsやcontext値が変化しない場合は
  自コンポーネントの再描画を抑制する
- 値をメモ化する

```js
const memoizedValue = useMemo(() => fn(a, b), [a, b])
```

````js
import React, { useState, useMemo } from "react"

const App = () => {
  const [count, setCount] = useState(0)
  const fn = (count) => countに対して何らかの計算処理を行う

  // 関数の実行結果の値をメモ化する
  const memoizedValue = useMemo(() => fn, [count])
  // countの値が変化するとfn()を実行する
  // 親コンポーネントの再描画時にはfn()を実行せず、メモ化した値を返す

  return (
    <>
      <p>{memoizedValue}</p>
      <button onClick={() => setCount(count + 1)}>+</button>
    </>
  )
}

export default App
```

## 参照
- [Hooks API Reference](https://reactjs.org/docs/hooks-reference.html#usememo)
