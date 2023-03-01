# `window.history`

```js
// 履歴を追加する
window.history.pushState({ page: 1 }, "", "?page=1")
window.history.back()    // http://...?page=1 に戻る (stateは { "page": 1 })
window.history.forward() // 元のページに戻る

// 履歴を置き換える
window.history.pushState({ page: 2 }, "", "?page=2")
window.history.replaceState({ page: 3 }, "", "?page=3")
window.history.go(2)  // http://...?page=3 に移動する (stateは { "page": 3 })
```

## 参照
- [History.pushState()](https://developer.mozilla.org/ja/docs/Web/API/History/pushState)
- [History.replaceState()](https://developer.mozilla.org/ja/docs/Web/API/History/replaceState)
