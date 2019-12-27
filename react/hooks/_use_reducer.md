# `useReducer`
- 参照: [React Hooks 入門 - Hooksと Redux を組み合わせて最新のフロントエンド状態管理手法を習得しよう！](https://www.udemy.com/course/react-hooks-101/)
- stateをreducerに渡し、reducerから新しいstateを返すためのhook
  - reducer -> stateとactionを受け取りaction.typeによってstateの値を変化させる純粋関数
```js
import React, { useReducer, useState } from 'react'

// reducerの定義
const bookReducer = (state = [], action) => {
  switch (action.type) {
    case: 'CREATE'
      const book = { title: action.title, author: action.author }
      const id = state.length === 0 ? 1 : state[length - 1].id + 1
      return [...state, { id, ...book }]
    case: 'DELETE'
      return state.filter(book => book.id !== action.id)
    case: 'RESET'
      return []
    default:
      return state
  }
}

const App = props => {
  // stateを扱うhookの定義
  const [state, setState] = useState(props)

  // reducerを扱うhookの定義
  const [state, dispatch] = useReducer(bookReducer, [])

  // onClick時に発火するイベントの定義
  // useReducerから定義したdispatchを呼ぶ
  const addBook = e => {
    e.preventDefault() // ボタンを押した際に画面のリロードを行わないようにする
    dispatch({ type: 'CREATE', title, author })
    setState(props) // defaultPropsを呼んでstateを空にする
  }
  const deleteBook = id => {
    e.preventDefault
    dispatch({ type: 'DELETE', id})
  }
  const resetBooks = e => {
    e.preventDefault
    dispatch({ type: 'RESET' })
  }

  const { title, author } = state

  // button要素のdesabled属性に真偽値を渡す
  const uncreatable = state.title !== '' && state.author !== ''
  const unresetable = state.length === 0

  return (
    <>
      <div>
        <input value={title} onChange={e => setState({ ...state, title: e.target.value })} />
        <input value={author} onChange={e => setState({ ...state, author: e.target.value })} />
        <button onClick={addBook} disabled={uncreatable}>Add</button>
      </div>
      <ul>
        {
          state.map(book => (
            <li key={book.id}>
              {book.title} by {book.author}
              <button onClick={deleteBook}>Delete</button>
            </li>
          )
        }
      </ul>
      <button onClick={resetBooks} disabled={unresetable}>Reset<button>
    </>
  )
}

App.defaultProps= {
  title: '',
  author: ''
}
```
