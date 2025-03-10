# Lodash
- JavaScript用のユーティリティライブラリ

##  導入
```
$ npm i -g npm
$ npm i --save lodash
```
```javascript
import React, { ReactElement, useState } from 'react'
import styled from '@emotion/styled'
import * as _ from 'lodash'

const BorderLine = styled.span`
  display: block;
  margin: 0 16px;
  border-bottom: 1px solid ${DesignSystemColors.bwGray5};
`

const ItemList = (props: Props): ReactElement => {
  const { items } = props

  return (
    <>
      <ul>
        {items.map((item: ReactElement) => (
          <>
            <li>{item}</li>
            {item !== _.last(items) && <BorderLine />}
          </>
        ))}
      </ul>
    </>
  )
}
```

## 参照
- [Lodash](https://lodash.com/)
