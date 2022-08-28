# ActiveModel
#### ActiveModel::AttributeAssignmentモジュール
- モデルの属性値へのアクセサメソッドに対してHashで値を割り当てる`assign_attributes`を提供する

#### ActiveModel::AttributeMethodsモジュール
- クラスのメソッドにカスタムのプレフィックスやサフィックスを追加できるようにする

#### ActiveModel::Attributesモジュール
- 属性を示す文字列をモデルの期待するデータ型に変換できるようにする

#### ActiveModel::Callbacksモジュール
- コールバックを定義できるようにする
- extendすることでPOROでコールバックを使用できるようになる
- ActiveModel::Validations::Callbacksと併せてincludeするとバリデーション系のコールバックも利用できる

#### ActiveModel::Conversionモジュール
- `persisted?`メソッドと`id`メソッドが定義されているクラスでRailsの変換メソッドを呼び出せるようにする

```ruby
class Person
  include ActiveModel::Conversion
  def persisted? = false
  def id =  nil
end

person = Person.new
person.to_model == person # => true
person.to_key # => nil
person.to_param # => nil
```

#### ActiveModel::Dirtyモジュール
- オブジェクトで変更が生じたかを検出 (属性値の変更の検知・変更前の値の取得) できるようにする
  - `changed?`
  - `changed`
  - `changed_attributes`
  - `changes` ...

#### ActiveModel::EachValidatorモジュール
- オブジェクトの個別の属性を検証するカスタムバリデータを作成する際の継承元クラス

#### ActiveModel::Namingモジュール
- モデル名を取得する`model_name`クラスメソッドを提供する

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```

#### ActiveModel::SecurePasswordモジュール
- 任意のパスワードを暗号化して安全に保存する手段を提供する
- bcrypt gemと併せて使用する
- モデルに`password_digest`属性が必要

```ruby
class Person
  include ActiveModel::SecurePassword

  # has_secure_passwordは以下のバリデーション機能を備えたpasswordアクセサを定義する
  # - パスワードが存在すること
  # - パスワードがXXX_confirmationで渡されたパスワード確認入力と等しいこと
  # - パスワードの最大長が72文字であること
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end
```

#### ActiveModel::Serialization
- オブジェクトに基本的なシリアライズ機能を提供する
  - シリアライズの対象となる属性 (文字列) を含むハッシュを宣言する必要がある

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes = {'name' => nil}
end

person = Person.new
person.serializable_hash # => {"name"=>nil}
person.name = "Bob"
person.serializable_hash # => {"name"=>"Bob"}
```

#### ActiveModel::Serializers::JSON
- JSONシリアライズ/デシリアライズを行う
- ActiveModel::Serializers::JSONをincludeするとActiveModel::Serializationが自動でincludeされる

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes = {'name' => nil}
end

person = Person.new
person.as_json # => {"name"=>nil}
person.name = "Bob"
person.as_json # => {"name"=>"Bob"}
```

#### ActiveModel::Translationモジュール
- オブジェクトとRails国際化 (i18n) フレームワーク間の統合を提供する
- `human_attribute_name`メソッドを定義してモデルオブジェクトがi18nによる変換を利用できるようにする

```yml
# config/locales/app.pt-BR.yml
pt-BR:
  activemodel:
    attributes:
      person:
        name: 'Nome'
```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

#### ActiveModel::Validationsモジュール
- バリデーション機能を提供する
- `errors`メソッドを提供する
  - DBとの接続が必要なバリデーションはActiveRecordによって提供されている

#### ActiveModel::Validatorモジュール
- カスタムバリデータを作成する際の継承元クラス

#### ActiveModel::Modelモジュール
- includeすることで基本的なモデルの機能を提供する
  - ActiveModel::AttributeAssignment
  - ActiveModel::Naming
  - ActiveModel::Conversion
  - ActiveModel::Translation
  - ActiveModel::Validations
- インスタンス化時に引数にHashを渡すとインスタンス変数に一括代入できるようにする機能を含む

## 参照
- 現場で使える Ruby on Rails 5速習実践ガイド
- [Active Model の基礎](https://railsguides.jp/active_model_basics.html)
