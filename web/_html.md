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

#### `a`タグ・`form`タグで使用できるHTTPメソッド
- `GET` / `POST`のみ
  - それ以外のメソッドを指定すると`GET`と解釈される
- `form`で`PUT` / `DELETE`を使用する場合、`hidden`属性を使用する必要がある
```html
<form action='/contents' method='POST'>
  <input type="hidden" name="_method" value="PUT">
  <input type="text" name="content">
  <input type="submit" value="Put">
</form>
```
```html
<form action='/contents' method='POST'>
  <input type='hidden' name='_method' value='DELETE'>
  <input type='submit' value='Delete'>
</form>
```

- `a`で`PUT` / `DELETE`を使用する場合、`deta-method`属性でメソッドを指定し、JSで操作を行う必要がある
  - Railsの場合はrails-ujsによって実行されている

### `autocomplete`
- 参照: [フォームの自動補完を無効にするには](https://developer.mozilla.org/ja/docs/Web/Security/Securing_your_site/Turning_off_form_autocompletion)
- ユーザー管理ページでブラウザの自動補完を無効化したい -> "autocomplete="new-password"
```haml
<input type='password' name='password' autocomplete='new-password'>
```
