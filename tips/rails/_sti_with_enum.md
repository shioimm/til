# enumを利用してSTIを実装する
- 参照: [enum の中身で処理が別れるようなコード](https://qiita.com/suusan2go/items/6da23826523744a74ba3#enum-%E3%81%AE%E3%82%AB%E3%83%A9%E3%83%A0%E3%82%92sti%E3%81%A7%E3%82%82%E4%BD%BF%E3%81%86)
- すでに存在しているモデルをSTI化する場合など

## Before
```ruby
class User < ActiveRecord::Base
  enum role: { staff: 0, customer: 1 }
end
```

## After
### スーパークラスの実装
```ruby
class User < ActiveRecord::Base
  self.inheritance_column = :role
  enum role: { staff: 0, customer: 1 }

  class << self
    # Railsが内部的に使用しているメソッドをオーバーライド
    def find_sti_class(role)
      role_name = roles.key(role.to_i)
      "User::#{role_name.to_s.camelize}".constantize
    end

    def sti_name
      roles[name.demodulize.underscore]
    end
  end
end
```

### サブクラスの実装
- 属性値はスーパークラスから引き継がれる
```ruby
module User
  class Staff < User
  end
end
```

```ruby
module User
  class Customer < User
  end
end
```

## STI化後、完全に独立したテーブルに変更していく場合の方向性
1. サブクラスごとに新しいテーブルを作成
2. 既存のテーブルから、該当するレコードを新しいテーブルへコピー
3. 既存のテーブルに対して関連を持っているテーブルに対し、
   新しいテーブルへの関連を持たせるためのカラムを追加
4. 2でコピーしたレコードのIDを3で追加したカラムに投入
5. 3の古いカラムを`ignored_columns=`に入れる
6. 問題がなければ3の古いカラムと元のテーブルを削除
