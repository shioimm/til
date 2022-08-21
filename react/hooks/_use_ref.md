# `useRef`
- ミュータブルなrefオブジェクト `{ current: initial }` を返す
- refオブジェクトはコンポーネントの存在期間全体にわたって存在する

```js
const refContainer = useRef(initial)
```

```js
import { useState, useEffect, useRef } from "react"
import ReactDOM from "react-dom/client"

const App = () => {
  const [inputValue, setInputValue] = useState("")
  const count = useRef(0)

  useEffect(() => count.current = count.current + 1)

  return (
    <>
      <p>{count.current}</p>
      <input type="text" value={inputValue} onChange={(e) => setInputValue(e.target.value)} />
    </>
  )
}
```
