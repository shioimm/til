# rails-ujs
- 参照: Ruby on Rails 6エンジニア養成読本 Rails 6からのイマドキフロントエンド開発
- JSを利用した画面制御を行うRails標準ライブラリ

## 用途
### カスタムデータ属性(`data-\*`)を扱う
```haml
= form.submit data: { confirm: 'Are you sure?', disabled_with: 'Sending...' }
```

### Ajax
```haml
<!-- デフォルトでAjax通信を行うため、レスポンスのContent-Typeがxhrになる -->

= form_with(model: user) do |f|
```
