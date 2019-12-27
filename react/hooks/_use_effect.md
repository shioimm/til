# `useEffect`
- 参照: [React Hooks 入門 - Hooksと Redux を組み合わせて最新のフロントエンド状態管理手法を習得しよう！](https://www.udemy.com/course/react-hooks-101/)
- 監視する対象に対してDOMを描画する際、もしくはDOMが変更された際にコールバックを実行するhook
  - 第一引数 -> コールバック関数
  - 第二引数 -> 監視する対象の配列(ex: `[state]`)

### 使い方
```js
import React, { useEffect, useState } from 'react'

const App = () => {
  useEffect(() => {
    console.log(2) // レンダリング後に実行される
  })

  const fuga = useEffect(() => {
    console.log(1) // レンダリング時にreturnの中で呼ばれる
    return 'fuga'
  })

  return (
    <>
      {fuga()}
    </>
  )
}
```
#### 最初にDOMを描画するタイミングでのみ`useEffect`を呼ぶ
- componentDidMountと同じ
```js
useEffect(() => {
  return 'hoge'
}, []) // 第二引数に空配列を渡す
```

#### stateの特定のプロパティの変更のみにフックする
```js
useEffect(() => {
  return 'hoge'
}, [state.city]) // 第二引数に対象となるプロパティを要素に取る配列を渡す
