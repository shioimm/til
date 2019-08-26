### SagaIterator

- yield に渡されるfunctionがredux-sagaに定義されているかチェック

```javascript
export function * hogeSaga (action) {
  yield functionNotImplemented() // <- エラーは出ない
}
```

```javascript
import { SagaIterator } from '@redux-saga/core'

export function * hogeSaga (action): SagaIterator {
  yield functionNotImplemented() // <- エラーが発生
}
```
