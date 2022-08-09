# JavaScriptモジュール
## CommonJS
- ウェブブラウザ環境外におけるJavaScriptの各種仕様 (Node.jsなど)

```js
// bar.js

module.exports = () => "bar";
```

```js
// 読み込むパッケージは現在のプロジェクトの`node_modules/`内に置く
const foo = require("foo");

// 自作のパッケージは相対パスで指定する
const bar = require("./bar");

console.log(bar());
```

## ES Modules
- Ecma Internationalのもとで標準化手続きが行われているJavaScriptの規格
  - スクリプト - 普通のJavaScriptファイル、グローバル名前空間に展開される
  - モジュール - `import`または`export`を1つ以上含むJavaScriptファイル、ES Modulesが適用される
    - 明示的にexportをつけた値だけが公開される
    - 常にstrict mode
    - `import`時に一度だけ評価される

```js
// bar.js

exports default () => "bar";
```

```js
// 読み込むパッケージは現在のプロジェクトの`node_modules/`内に置く
import * from "foo";

// 自作のパッケージは相対パスで指定する
import bar from "./bar";

console.log(bar());
```
