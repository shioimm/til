# `useContext`
- 参照: [React Hooks 入門 - Hooksと Redux を組み合わせて最新のフロントエンド状態管理手法を習得しよう！](https://www.udemy.com/course/react-hooks-101/)
- コンテキストを共有する(Prop Grilling問題を回避する)ためのhook
- 共有したいデータを渡す側(Provider)と、共有したいデータを受け取る側(Consumer)の双方に読み込んで使う
```js
// app/javascript/contexts/MyContext.js

import { createContext } from 'react'

const MyContext = createContext()

export default MyContext
```

```js
// app/javascript/components/App.js

import React, { useState } from 'react'
import MyContext from 'contexts/MyContext'
import City from 'components/app/City'

const App = props => {
  const [state, setState] = useState(props)
  const { city } = state

  return (
    // 使用したい箇所をProviderコンポーネントで囲む
    // valueに共有したいデータを渡す
    <MyContext.Provider value={{ state }}>
      <City />
      <input value={city} onChange={e => setState({ ...state, city: e.target.value })} />
      <button onClick={() => setState(props)}>reset</button>
    </MyContext.Provider>
  )
}

App.defaultProps = {
  city: 'Fukuoka',
}
```

```js
// app/javascript/components/app/city.js

import React, { useState } from 'react'
import MyContext from 'contexts/MyContext'

const { state } = useContext(MyContext) // コンテキストからvalueを取り出す

const App = () => {
  return <p>City: {state.city}</p>
}

export default City
```
