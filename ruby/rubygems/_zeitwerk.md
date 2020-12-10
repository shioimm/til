# zeitwerk
## Rails 6とZeitwerk
### Zeitwerkとclassic modeの違い
- Zeitwerk
  - 独立したgem
  - ディレクトリを読み込んでファイル名から定数を推察し、`Module#autoload`を利用してオートロードを行う
- classic mode
  - Railsの一部
  - 定数(クラス名)に対して`Module#const_missing`(をオーバーライドしたメソッド)を呼び出してファイル探索し、
  見つけたファイルに対して`require`|`load`することでオートロードを行う

### classic modeの問題とZeitwerkが解決できること
- ネストしたモジュールにおいて、ロードされる順番によって同名の別モジュールを呼び出すことがあった

```ruby
# app/models/user.rb
class User < ApplicationRecord
end

# app/models/admin/user.rb
module Admin
  class User < ApplicationRecord
  end
end

# app/models/admin/user_manager.rb
module Admin
  class UserManager
    def self.all
      User.all # Want to load all admin users
    end
  end
end
```

- 【意図】UserManagerは`User.all`で`Admin::User.all`したい
- 【結果】`Admin::User`が`User`よりも先にロードされていないと、`User.all`の結果が返る
- Zeitwerkの場合、ディレクトリ構造を考慮するため、UserManagerは必ず`Admin::User`を参照する

- 参照: [Understanding Zeitwerk in Rails 6](https://medium.com/cedarcode/understanding-zeitwerk-in-rails-6-f168a9f09a1f)
