# ActiveModel
#### ActiveModel::AttributeAssignment
- モデルの属性値へのアクセサメソッドに対してHashで値を割り当てる`assign_attributes`を提供する

#### ActiveModel::Attributes
- 属性を示す文字列をモデルの期待するデータ型に変換する

#### ActiveModel::Callbacks
- コールバックを定義できるようになる
- extendすることでPOROでコールバックを使用できるようになる
- ActiveModel::Validations::Callbacksと併せてincludeするとバリデーション系のコールバックも利用できる

#### ActiveModel::Conversion
- オブジェクトの持つ情報からURLパラメータの作成やパーシャルのパス解決をする

#### ActiveModel::Dirty
- 属性値の変更の検知や変更前の値の取得を行う

#### ActiveModel::EachValidator
- オブジェクトの個別の属性を検証するカスタムバリデータを作成する際の継承元クラス

#### ActiveModel::Naming
- モデル名を取得する`model_name`クラスメソッドを提供する

#### ActiveModel::Translation
- `human_attribute_name`メソッドを定義してモデルオブジェクトがi18nによる変換を利用できるようにする

#### ActiveModel::Validations
- バリデーション機能を提供する
- `errors`メソッドを提供する
  - DBとの接続が必要なバリデーションはActiveRecordによって提供されている

#### ActiveModel::Validator
- カスタムバリデータを作成する際の継承元クラス

#### ActiveModel::Model
- includeすることで基本的なモデルの機能を提供する
  - ActiveModel::AttributeAssignment
  - ActiveModel::Naming
  - ActiveModel::Conversion
  - ActiveModel::Translation
  - ActiveModel::Validations
- インスタンス化時に引数にHashを渡すとインスタンス変数に一括代入できるようにする機能を含む

## 参照
- 現場で使える Ruby on Rails 5速習実践ガイド
