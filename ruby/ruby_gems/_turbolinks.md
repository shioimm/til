# turbolinks
- 参照: 現場で使える Ruby on Rails 5速習実践ガイドP340-343

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
