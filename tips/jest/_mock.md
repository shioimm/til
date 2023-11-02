# サーバーとの通信をモックする
- モックする関数を別ファイルに切り出す

```js
// AppUtils.js (モックする関数を格納する)

import axios from 'axios'

export const fetchAppStatus = ((id) => {
  let appStatus
  axios({
    method: 'get',
    url: `api/v1/apps/${id}`
  }).then((response) => {
    appStatus = response.data.function.status
  })
  return appStatus
})
```

```js
// App/index.js

import * as React from 'react'
import { fetchAppStatus } from './AppUtils'
const [appStatus, changeAppStatus] = React.useState(false)

React.useEffect(() => {
  const appStatus = fetchStudentStatus(id)
  changeAppStatus(appStatus)
}, [id])
```

```js
// test.js
import App from 'containers/App/index'
import * as appUtil from 'containers/App/AppUtils'

let spy

beforeEach(() => {
  spy = jest.spyOn(appUtil, 'appStatus')
  spy.mockReturnValue(true)
})

afterEach(() => {
  spy.mockReset();
})
```
