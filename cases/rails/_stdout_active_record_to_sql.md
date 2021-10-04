# コンソールにSQLを表示する
- 対象がActiveRecord:Relationの場合
```ruby
Book.find_by(title: 'Programming Ruby').chapters.to_sql
```

- 対象がActiveRecord:Relationではない場合
```ruby
ActiveRecord::Base.logger = Logger.new(STDOUT)

Book.find_by(title: 'Programming Ruby').chapters.find_by(name: 'Ruby.new')
```
