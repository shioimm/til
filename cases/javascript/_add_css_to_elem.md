# DOM要素にCSSスタイルを追加する
- [CSSStyleDeclaration](https://developer.mozilla.org/ja/docs/Web/API/CSSStyleDeclaration)

```js
const alert = document.getElementById('alert') as HTMLElement

// 一つだけ追加
alert.style.zIndex = '1000'

// まとめて追加
alert.style.cssText = 'display: block; position: absolute'
```
