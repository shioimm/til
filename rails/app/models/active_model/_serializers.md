# ActiveModel::Serializers
- 参照: 現場で使える Ruby on Rails 5速習実践ガイドP426-427

## ::JSON
- `Object#to_json`の拡張モジュール
- オブジェクトにシリアライズ機能を追加
- 参照: [Active Model の基礎 1.8 シリアライズ](https://railsguides.jp/active_model_basics.html#%E3%82%B7%E3%83%AA%E3%82%A2%E3%83%A9%E3%82%A4%E3%82%BA)
- 参照: [Ruby on Rails 6.0.2.1 RDOC_MAIN.rdoc](https://api.rubyonrails.org/)

```ruby
class Article
  include ActiveModel::Serialization

  attr_accessor :title

  def attributes
    { 'title' => nil } # 属性名は文字列であること
  end
end
```
```ruby
pry(main)> article = Article.new
=> #<Article:0x00007fb9e08d8f78>
pry(main)> article.serializable_hash
=> {"title"=>nil}
pry(main)> article.title = 'Programming Ruby'
=> "Programming Ruby"
pry(main)> article.serializable_hash
=> {"title"=>"Programming Ruby"}
```
### オプション
- `only:` -> 特定の属性のみ返す
- `except:` -> 特定の属性を除いて返す
- `methods:` -> メソッドの呼び出し結果を合わせて返す
- `include:` -> 関連モデルを含めて返す

### ActiveModel::Serializers::JSONモジュール
- JSONシリアライズ/デシリアライズを行う
- `to_json` `as_json`を使用できる
  - `to_json` `as_json`は内部で`serializable_hash`を呼んでいる
  - 出力するJSONを噛ま各カスタマイズしたい場合は`serializable_hash`を使用する
```
article = Person.new
article.serializable_hash   # => {"title"=>nil}
article.as_json             # => {"title"=>nil}
article.to_json             # => "{\"title\":null}"

article.title = "Programming Ruby"
article.serializable_hash   # => {"title"=>"Programming Ruby"}
article.as_json             # => {"title"=>"Programming Ruby"}
article.to_json             # => "{\"title\":\"Programming Ruby\"}"
```

#### `to_json`と`as_json`の違い
- `to_json`
  - オブジェクトをJsonに変換
```ruby
{ hoge: :fuga }.to_json
# =>  "{\"hoge\":\"fuga\"}"
```

- `as_json`
  -  オブジェクトをハッシュロケットを使用したハッシュに変換
```ruby
{ hoge: :fuga }.as_json
# => { "hoge" => "fuga" }
```

