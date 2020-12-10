# rails-ujs
- 参照: Ruby on Rails 6エンジニア養成読本 Rails 6からのイマドキフロントエンド開発
- 参照: 現場で使える Ruby on Rails 5速習実践ガイドP335-336
- JSを利用した画面制御を行うRails標準ライブラリ

## 用途
### カスタムデータ属性(`data-\*`)を扱う
```haml
= link_to 'Delete', @user, method: :delete, remote: true, data: { confirm: 'Are you sure?' }
```
- `data-method`属性
- `data-remote`属性
- `data-confirm`属性

### Ajax通信を行う
```haml
= # デフォルトでAjax通信を行うため、レスポンスのContent-Typeがxhrになる
= form_with(model: user) do |f|
```
```js
// ajax:successイベント
// レスポンスのステータスコード2xx系の場合にイベントを発火する
document.addEventListener('turbolinks:load', function() {
  document.querySelector('.hoge').forEach(function(x) {
    x.addEventListener('ajax:success', function() {
      // ...
    })
  })
})
```
