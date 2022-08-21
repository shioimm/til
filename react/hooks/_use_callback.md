# `useCallback`
- 親コンポーネントの再描画時、自コンポーネントのpropsやcontext値が変化しない場合は
  自コンポーネントの再描画を抑制する
- 関数をメモ化する

```js
const memoizedCallback = useCallback(() => fn(a, b), [a, b])
```

```js
import React, { useState, useEffect, useCallback } from "react"

const App = () => {
  const [countHeavy, setCountHeavy] = useState(0)

  const fn = (count) => // 何らかの計算処理を行う

  // 関数をメモ化する
  const memoizedCallback = useCallback(fn, [count])
  // countの値が変化するとfn()を返す
  // 親コンポーネントの再描画時にはメモ化した関数を返す

  // countボタンがクリックされると実行される
  useEffect(() => {
    fn(count)
  }, [memoizedCallback])

  return (
    <>
      <p>{count}</p>
      <button onClick={() => setCount(count + 1)}>+</button>
    </>
  )
}

export default App
```

## 参照
- [Hooks API Reference](https://reactjs.org/docs/hooks-reference.html#usecallback)
