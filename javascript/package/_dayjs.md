# Dayjs
## 日付操作
```js
import * as dayjs from 'dayjs'
import * as isSameOrAfter from 'dayjs/plugin/isSameOrAfter'
import * as isSameOrBefore from 'dayjs/plugin/isSameOrBefore'

const now = dayjs()
const datetime = dayjs('1970-01-01')

now.isBefore(datetime)
now.diff(datetime, 'year')
```

## タイムゾーン
```js
import * as dayjs from 'dayjs'
import * as utc from 'dayjs/plugin/utc'
import * as timezone from 'dayjs/plugin/timezone'

dayjs.extend(utc)
dayjs.extend(timezone)

dayjs.tz.setDefault('Asia/Tokyo')
dayjs().tz()
```

- [Day.jsの.tz.setDefault()が動かないと思ったけど使い方が間違ってただけだった](https://dev.classmethod.jp/articles/day-js-timezone-set-default/)

## ロケール
```js
import * as dayjs from 'dayjs'
import 'dayjs/locale/ja'

dayjs.locale('ja')
```

## 参照
- [Installation Guide](https://day.js.org/docs/en/installation/installation)
- [API Reference](https://day.js.org/docs/en/parse/parse)
