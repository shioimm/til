# `useReducer`
- reducerを受け通り、現在のstateをdispatch メソッドとペアにして返します
  - reducer - stateとactionを受け取りaction.typeによってstateの値を変化させる純粋関数

```js
const [state, dispatch] = useReducer(reducer, initialArg);
```

- 第一引数 -> reducer (`(state, action) => newState`)
- 第二引数 -> stateの初期値

```js
import React, { useReducer } from 'react';

const initialState = {
  count: 0
}

const reducer = (state, action) => {
  switch(action){
    case 'INC':
      return { count: state.count++ }
    case 'DEC':
      return { count: state.count-- }
    default:
      return state
  }
}

const  Counter => () {
  const [state, dispatch] = useReducer(reducer, initialState)

  return (
    <div>
      <h1>Count: { state.count }</h1>
      <button onClick={() => dispatch('INC')}>+</button>
      <button onClick={() => dispatch('DEC')}>-</button>
    </div>
  )
}

export default Counter;
```
