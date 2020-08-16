# turbolinks
- 参照: 現場で使える Ruby on Rails 5速習実践ガイドP340-343

## TL;DR
### 仕組み
- a要素へのクリックイベントにフックして遷移先のページをAjaxで取得する
- ページが要求するアセッツが現在と同一のものであればそのまま利用し、titleやbodyは置き換える

### 注意
- リクエストごとにページ遷移が発生しない(ブラウザがアセッツを評価しない)ため、
  `window.onload` `DOMContentLoaded`が発火しない
  -  対策: `turbolinks:load`を使用する
```js
document.addEventListener('turbolinks:load', function() {
  // ...
}
```
- bodyタグの中にscriptを書くと、そのページに遷移するたびにturbolinksがscriptを実行してしまう
  - 対策: scriptはheadタグの中に書く

### 無効化
- gem 'turbolinks'をアンインストール
- マニフェストファイルから`//= require turbolinks`の行を削除
- レイアウトファイルから`'data-turbolinks-track': 'reload'`属性を削除

## 実装
### `form_with`からGETで送信されたajaxリクエストを有効化する
- `form_with`をリンクと同じように扱えるようにする
  - 参照: パーフェクトRuby on Rails[増補改訂版] P398
```js
// app/javascript/get_form_turbolinks.js

import Turbolinks from 'turbolinks'

document.addEventListener("turbolinks:load", function(event) {
  const forms = document.querySelectorAll("form[method=get][data-remote=true]")

  for (const form of forms) {
    form.addEventListener("ajax:beforeSend", function(event) {
      const options = event.detail[1]

      Turbolinks.visit(options.url)
      event.preventDefault()
    })
  }
})
```

```js
// app/javascript/packs/applications.js

require("get_form_turbolinks")
```
