# ActionText
- Railsが標準で提供するリッチテキスト機能

### ActionTextが提供する機能
- WYSIWYGエディタ
- リッチテキストコンテンツを保存するモデル
- リッチテキストを取り扱うヘルパーメソッド群

## Usage
```
# ActionTextのマイグレーションファイルを生成
# ActiveStorage::Blob/ActiveStorage::Attachmentがない場合はそのマイグレーションファイルも生成
# Trixのnpmパッケージをインストール
# CSSファイルの生成
$ rails action_text:install

$ rails db:migrate
```

```ruby
class Xxx < ApplicationRecord
  has_rich_text :xxx # リッチテキストを利用する属性
end
```

```haml
= form_with(model: xxx, local: true) do |form|
  = form.rich_text_area :xxx
```

```ruby
# app/controllers/xxx_controller.rb

def index
  @xxx = Xxx.with_rich_text_xxx
  # with_rich_text_xxx - ActiveStorageのモデルに対してeager_loadを行う
end
```

## 参照
- パーフェクトRuby on Rails[増補改訂版] P254-260
