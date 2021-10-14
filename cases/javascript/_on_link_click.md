# リンククリック時にonClickイベントを呼ぶ
```
import { createBrowserHistory } from 'history'

const history = createBrowserHistory()

<a href='' onClick={() => history.goBack()}>
  戻る
</a>
```
