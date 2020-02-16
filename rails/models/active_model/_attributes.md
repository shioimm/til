# ActiveModel::Attributes
- 参照: 現場で使える Ruby on Rails 5速習実践ガイドP426-427
- 属性を示す文字列をモデルの期待するデータ型に変換する

# Attribute Methods
### `(属性名)_before_type_cast`
- 参照; [rails/validatesでbefore_type_cast](https://dora.bk.tsukuba.ac.jp/~takeuchi/?%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2%2Frails%2Fvalidates%E3%81%A7before_type_cast)
- controllerでparamsから取得できるパラメータは文字列 -> ActiveRecordへ代入される際にモデルの各属性のデータ型に変換される
- 型変換前のデータが欲しい場合、`(属性名)_before_type_cast`を使用すると文字列としてデータを取得できる

#### 使い所
- レコードのデータを元に辞書ファイルから曜日を引きたい
```yml
# config/locales/ja.yml
ja:
  date:
    day_names: [日曜日, 月曜日, 火曜日, 水曜日, 木曜日, 金曜日, 土曜日]
```
```ruby
# app/models/diary.rb
# daynameはenumで定義されている
enum dayname: %i[sunday monday tuesday wednesday thursday friday saturday]
```
```ruby
I18n.t("date.day_names")[diary.dayname_before_type_cast]
```
