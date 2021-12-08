# importmap
- ES Modulesのimport文でソースを指定する際、相対パス・絶対パスではなく
  パッケージ名を指定することで解決できるようにする仕組み
- マッピングの設定 (パッケージ名とパッケージのパスを対応づける) が必要
- Chrome89以降で利用可能

```js
import moment from "moment"
import { partition } from "lodash"
```

```js
<script type="importmap">
{
  "imports": {
    "moment": "/node_modules/moment/src/moment.js",
    "lodash": "/node_modules/lodash-es/lodash.js"
  }
}
</script>
```

#### import mapの導入意義
- トランスパイルやファイルのバンドル (結合) なしで
  ESM (ES Modules) 向けJavaScriptライブラリを用いることができるようになる
  - Webpack、Yarn、npm、その他のJavaScriptツールチェインが不要となる

#### shim
- [shim](https://github.com/guybedford/es-module-shims)
- ESMをサポートしているがChrome89+ではないブラウザでimportmapを利用できるようにするためのポリフィル

## 参照
- [WICG/import-maps](https://github.com/WICG/import-maps)
- [JavaScriptのバンドルとトランスパイルが不要なモダンWebアプリ](https://postd.cc/modern-web-apps-without-javascript-bundling-or-transpiling/)
- [rails/importmap-rails](https://techracho.bpsinc.jp/hachi8833/2021_10_07/112183)
