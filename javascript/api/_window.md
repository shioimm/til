# window
- DOM documentを収めるウィンドウを指す

## `window.localStorage`
- 特定のドメインのローカルストレージAPIを操作するメソッド

```js
// key, valueは文字列で渡す
window.localStorage.setItem('Book', 'Programming Ruby')

const book = window.localStorage.getItem('Book') // => 'Programming Ruby'

window.localStorage.removeItem('Book')
// or
window.localStorage.clear()
```

## 参照
- [window](https://developer.mozilla.org/ja/docs/Web/API/Window)
