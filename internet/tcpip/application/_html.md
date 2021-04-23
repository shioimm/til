# HTML
- 参照: よくわかるHTTP/2の教科書P12
- メタ情報(head) + 内容・構造(body)
- ブラウザはメタ情報を参考にしてWebページやタイトルを表示する

### `<iframe>`要素
- 参照: [\<iframe\>: インラインフレーム要素](https://developer.mozilla.org/ja/docs/Web/HTML/Element/iframe)
- 入れ子になった閲覧コンテキストを利用して、現在のHTMLページに他のページを埋め込むための要素
- `allow`属性
  - 機能ポリシーの指定
- `allowfullscreen`属性
  - `Element.requestFullscreen()`を呼び出して全画面モードにすることができる場合true
  - allow="fullscreen"と同じ

### `<object>`要素
- 参照: [\<object\>](https://developer.mozilla.org/ja/docs/Web/HTML/Element/object)
- 参照: [\<object\> 文書に外部リソースを埋め込む](http://www.htmq.com/html5/object.shtml)
- 画像、内部の閲覧コンテキスト、プラグインによって扱われるリソースなど外部リソースを埋め込むための要素
- `<embed>`がプラグインを必要とするデータを埋め込むのに対して、`<object>`には外部リソース全般を指定する

### `<embed>`要素
- 参照: [\<embed\>: 埋め込み外部コンテンツ要素](https://developer.mozilla.org/ja/docs/Web/HTML/Element/embed)
- 外部のコンテンツを文書中の指定された場所に埋め込むための要素
- コンテンツは外部アプリケーションや、ブラウザーのプラグインなどによって提供される
- 最近のブラウザはプラグインの対応を非推奨にして削除している傾向にあるため使用しないことが推奨される

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
