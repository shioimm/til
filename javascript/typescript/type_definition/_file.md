# 型定義ファイル
### 公開されている型定義ファイルを導入する (既存のJavaScriptライブラリに型付けする場合など)
- npmリポジトリから型定義ファイルをインストールする

```
$ npm install --save-dev @types/<LibraryName>
```

- ライブラリ自身に型定義ファイルが同梱されている場合はインストール不要

### 型定義ファイルを自作する
- `.d.ts`拡張子の型定義ファイルを自作する

```js
// ./lib/fn.js
exports.fn = function(name) {
  console.log(`Hello, ${name}`)
}
```

```js
// ./lib/fn.d.ts
export function f(name: string): void
```

```js
import { fn } from './lib/fn'

fn('string')
```
