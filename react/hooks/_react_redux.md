# `useSelector` / `useDispatch`

```js
import { useDispatch, useSelector } from 'react-redux'
import * as collectionModule from 'modules/Collection'

const fetchedCollection = useSelector((state) => collectionModule.fetchCollection(state))

const dispatch = useDispatch()
dispatch(collectionModule.push(1))
```
