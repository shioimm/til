# `import` / `require`
#### `import` (ESM)
- ES6の仕様
- ES6対応ブラウザで動作する

```js
// module.js

export const hello = () => {
  console.log('hello')
}
```

```js
import { hello } from './module'

hello();
```

#### `require` (CJS)
- CommonJSの仕様
- Node.jsで動作し、ブラウザで実行されるJSでは動作しない
- import構文をbabelに通すとrequire文に変換される

```js
// module.js
module.exports = function() {
  console.log('hello')
}
```

```js
const helloModule = require('./module.js')

helloModule()
```

## 参照
- [jsのimportとrequireの違い](https://qiita.com/minato-naka/items/39ecc285d1e37226a283)
