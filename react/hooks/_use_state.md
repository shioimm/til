# `useState`
- 参照: [React Hooks 入門 - Hooksと Redux を組み合わせて最新のフロントエンド状態管理手法を習得しよう！](https://www.udemy.com/course/react-hooks-101/)
- stateを使うためのhook
```js
import React, { useState } from 'react'

const App = () => {
  const [cout, setCount] = useState(0)
  // 引数0は初期値
  // useState(0)の返り値は[0, function()]の配列
  //// 0 -> state
  //// function() -> stateを操作する関数

  const increment = () => setCount(count + 1)
  // stateを操作した結果の値を引数に渡す

  const decrement = () => setCount(prevCount => prevCount - 1)
  // 引数に関数を渡すこともできる
  // 関数の引数には現在のstateが入る

  return (
    <> // React.Fragmentの略
      <div>count: {count}</div>
      <button onClick={increment}>+</button>
      <button onclick={decrement}>-</button>
    </>
  )
}
```
