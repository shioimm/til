# `useContext`
- コンテキストオブジェクトを共有する
- コンテキストを渡す側 (Provider) と、コンテキストを受け取る側 (Consumer) の双方に読み込んで使う

```js
const MyContext = createContext()

const count = useContext(MyContext)
```

```js
import React, { useContext } from 'react'

const MyContext = createContext(99) // 初期値

const App = () => {
  return (
    <>
      <MyContext.Provider value={100}> // コンテキストへデータを渡す
        <Number />
      </MyContext.Provider>
    </>
  )
}

const Number = () => {
  const n = useContext(myContext) // Providerのデータを取得
  return <p>{n}</p> // 100
}
```
