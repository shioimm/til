# importmap
- ES Modulesのimport文でソースを指定する際、相対パス・絶対パスではなく
  パッケージ名を指定することでも解決できるようにする仕組み
- マッピングの設定 (パッケージ名とパッケージのパスを対応づけるマッピングの設定が必要

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

## 参照
- [WICG/import-maps](https://github.com/WICG/import-maps)
- [JavaScriptのバンドルとトランスパイルが不要なモダンWebアプリ](https://postd.cc/modern-web-apps-without-javascript-bundling-or-transpiling/)
