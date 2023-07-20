# ActiveSupport::CurrentAttributes
- グローバルステートを扱うためのクラス

## e.g. コントローラー以外で`current_user`を扱いたい

```ruby
# app/models/current_user.rb

class CurrentUser < ActiveSupport::CurrentAttributes
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
      CurrentUser.user = current_user
    end
end
```

```ruby
# テスト実行時、前回の`CurrentUser.user`の情報が残っている場合は`CurrentUser.reset`が必要

require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    CurrentUser.reset
  end
end
```
