# Turbolinks
- すべてのリンクをAjaxで置き換えるライブラリ
  - クリックイベントにフックして遷移先のページをAjaxで取得する
- 受け取ったHTMLのうち、`<body>`のみを差し替える
- JSやCSSのダウンロード・パースを行わないため高速にレンダーできる

#### 弱点
- クリックイベント発生時にページ遷移しない (ブラウザがJS / CSSを評価しない) ため、
  `window.onload`・`DOMContentLoaded`が発火しない
  - `addEventListener`に`turbolinks:load`を指定することで回避する

```js
document.addEventListener('turbolinks:load', function() {
  // ...
}
```

- `<body>`の中にスクリプトを書いた場合、
  そのページに遷移するたびにTurbolinksがスクリプトを実行する
  - スクリプトを`<head>`の中にのみ書くことで回避する
- ページロードは多くの場合一回のみ行われるので高速化の恩恵を受けづらい
- E2Eテストで明示的にDOM要素を監視しなければいけない
- formに対応していない

#### 無効化
- `gem 'turbolinks'`を削除
- マニフェストファイルから`//= require turbolinks`の行を削除
- レイアウトファイルから`'data-turbolinks-track': 'reload'`属性を削除

## 参照
- [クライアント側のJavaScriptを最小限にするHotwire](https://logmi.jp/tech/articles/324219)
- 現場で使える Ruby on Rails 5速習実践ガイドP340-343
