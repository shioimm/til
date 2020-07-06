# ActiveSupport
- 参照: [RDOC_MAIN.rdoc](https://api.rubyonrails.org/)

## Module::Concerning
- 参照: [Module::Concerning](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html#method-i-concerning)
- models/concernsディレクトリ内にファイルを作成せず、モデルクラス内で関心事の分離を行う
- `Module::Concerning#concerning` -> 新しいconcernを定義し、Mixinする
```ruby
class Chapter < ApplicationRecord
  belongs_to :book

  concerning :RangeCompactionable do
    delegate :begin, :end, :cover?, to: :range

    private

      def range
        @range ||= starts_at..ends_at
      end
  end
end
```

## Enumerable
### #index_with(default = INDEX_WITH_DEFAULT)
- 配列の要素をkey、ブロック内の返り値をvalueとしてハッシュに変換する
- `#each_with_object({})`に代用できる
```ruby
# Before
book = Book.new(title: 'Programming Ruby', author: 'Dave Thomas')

%i[title author].each_with_object({}) do |attr, hash|
  hash[attr] = post.public_send(attr)
end
# => { title: 'Programming Ruby', author: 'Dave Thomas' }

# After
book = Book.new(title: 'Programming Ruby', author: 'Dave Thomas')

%i[title author].index_with { |attr| post.public_send(attr) }
# => { title: 'Programming Ruby', author: 'Dave Thomas' }
```

## Object
### #presence_in(another_object)
- レシーバがanother_objectに含まれている場合はレシーバを返し、含まれていない場合は`nil`を返す
- `another_object.respond_to?(:include?)`が`false`の場合、`ArgumentError`が発生する

## ActiveSupport::CurrentAttributes
- コントローラー以外で`Current.user`(`current_user`)を扱う
```ruby
# app/models/current.rb

class Current < ActiveSupport::CurrentAttributes
  attribute :account, :user

  # NOTE: DO NOT USE EXCEPT IN ApplicationController#set_current_user
  def user=(user)
    super
    self.account = user
  end
end
```

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  private

    def set_current_user
      Current.user = current_user
    end
end
```

- テスト実行時、前回の`Current.user`の情報が残っている場合は
  `Current.reset`が必要
```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    Current.reset
  end
end
```
