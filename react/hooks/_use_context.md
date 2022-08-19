# `useContext`
- コンテキストオブジェクトを共有する
- コンテキストを渡す側 (Provider) と、コンテキストを受け取る側 (Consumer) の双方に読み込んで使う

```js
const count = useContext(MyContext);
```

```js
// app/javascript/contexts/MyContext.js

import { createContext } from 'react'

const MyContext = createContext()

export default MyContext

// ------------------------------------

// app/javascript/components/app/count.js

import React, { useState } from 'react'
import MyContext from 'contexts/MyContext'

const { state } = useContext(MyContext) // コンテキストからcountを取り出す

const Count = () => {
  return <p>count: {state.count}</p>
}

export default Count

// ------------------------------------

// app/javascript/components/App.js

import React, { useState } from 'react'
import MyContext from 'contexts/MyContext'
import Count from 'components/app/Count'

const App = () => {
  const [state, setState] = useState(0)
  const { count } = state

  return (
    // 使用したい箇所をProviderコンポーネントで囲む
    // countに共有したいデータを渡す
    <MyContext.Provider value={{ state }}>
      <Count />
      <button onClick={() => setState(...state, count: count++)}>+</button>
    </MyContext.Provider>
  )
}
```
