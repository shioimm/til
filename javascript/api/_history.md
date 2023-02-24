# `window.history`

```js
// 履歴を追加する
window.history.pushState({page: 1}, "title 1", "?page=1")
window.history.back()    // http://example.com/example.html?page=1 | state: {"page":1} に戻る
window.history.forward() // 元のページに戻る

// 履歴を置き換える
window.history.pushState({page: 2}, "title 2", "?page=2")
window.history.replaceState({page: 3}, "title 3", "?page=3")
window.history.go(2)  // http://example.com/example.html?page=3 | state: {"page":3}" に移動する
```
