## config/locales/models/ja.ymlファイルを書きたい
### ActiveModel::Modelをincludeしたクラスの場合
```ruby
class Hoge
  include ActiveModel::Model

  attr_reader :fuga
end
```
```yml
ja:
  activemodel:
    attributes:
      hoge:
        fuga: ふが
```

### ActiveModel::Modelをincludeしたmodule配下のクラスの場合
```ruby
module Moge
  class Hoge
    include ActiveModel::Model

    attr_reader :fuga
  end
end
```
```yml
ja:
  activemodel:
    attributes:
      moge/hoge:
        fuga: ふが
```

## Serviceクラスetc...をi18n対応したい
### 1. config/localesディレクトリ以下のファイルを読み込めるようにする

```config/application.rb
config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
```

### 2. config/servicesディレクトリにja.ymlファイルを追加する
```yml
ja:
  module_name:
    class_name:
      追加したい単語: 'xxxxxxxxxxxx'
```

```yml
# 今回の場合
# config/locales/services/ja.yml

ja:
  articles:
    update_service:
      record_invalid: '掲載校舎から自分の所属していない校舎を削除することはできません'
```

### 3. Serviceクラス側で読み込む

```ruby
I18n.t('.module_name.class_name.record_invalid')
```

```ruby
# 今回の場合
# app/services/articles/update_service.rb

def execute
  raise ActiveRecord::RecordInvalid if invalid_record?

  article.update(article_params)
  true
rescue ActiveRecord::RecordInvalid => e
  ErrorUtility.logger e
  article.errors.add(:base, I18n.t('.articles.update_service.record_invalid'))
  false
end
```
