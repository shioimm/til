# ActiveRecord::ModelSchema
## `inheritance_column=`
- 前提: Railsでは`type`属性はSTIのクラス名を格納するための属性名として予約されている
- 1.STI化時、type以外のカラムにクラス名を格納できるようにする
```ruby
class User < ApplicationRecord
  self.inheritance_column = :role
end
```
- 2.STIを無効化し`type`を通常の属性値として使用できるようにする
```ruby
class User < ApplicationRecord
  self.inheritance_column = :type
end
```

## `ignored_columns=`
- ARに対して隠蔽するカラムを設定する

```ruby
class Hoge < ApplicationRecord
  # fugaにアクセスすることができなくなる
  self.ignored_columns = %[fuga]
end

# 使い所
# 1. 削除する予定のカラムに対して設定する
#    カラム削除前後のトラブルを回避する
# 2. STIの子モデルのうち、特定のモデルのみが使う属性に対してバリデーションをかけたい
#    他のモデルでは使わない属性のため、ignored_columnsで隠蔽する
```
