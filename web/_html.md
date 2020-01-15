# HTML
### `data-`属性(カスタムデータ属性)
- 参照: [data-\*](https://developer.mozilla.org/ja/docs/Web/HTML/Global_attributes/data-*)
- JSからHTMLを操作する際に利用することができる属性
- 属性を設定した要素のHTMLElementインターフェイスからカスタムデータにアクセスすることができる
```html
<div id="hoge" data-x="x">
```
```js
const element = document.getElementById('hoge')
let value = element.dataset.x // => 'x'
value = element.getAttribute('data-x') // => 'x'
```
