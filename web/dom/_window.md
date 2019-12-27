# window
- 参照: [window](https://developer.mozilla.org/ja/docs/Web/API/Window)
- DOM documentを収めるウィンドウを指す

## `window.localStrage`
- 特定のドメインのローカルストレージAPIを操作するメソッド
```js
// key, valueは文字列で渡す
window.localStorage.setItem('Book', 'Programming Ruby')

let cat = window.localStorage.getItem('Book') // => 'Programming Ruby'

window.localStorage.removeItem('Book')
// or
window.localStrage.clear()
```
