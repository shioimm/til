# ActiveSupport::CurrentAttributes
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

- テスト実行時、前回の`Current.user`の情報が残っている場合は`Current.reset`が必要

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    Current.reset
  end
end
```
