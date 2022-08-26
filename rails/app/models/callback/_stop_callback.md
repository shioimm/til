# コールバックの停止
- コールバックに`throw :abort`を記述することで操作を停止し、ロールバックを行う

```ruby
# 不可逆的な処理を行った後のレコードを削除したくない場合など
class Pocket < ApplicationRecord
  before_destroy :bitten_biscuit?

  def bitten_biscuit?
    if self.biscuit.bitten?
      errors.add(:biscuit, 'is bitten!')
      throw :abort
    end
  end
end
```

- Railsアプリケーション内で`throw`されたコードはRailsが`catch`する
- RSpec内では`catch`されないため、明示的に`catch`する必要がある

```ruby
describe 'validate_destroying' do
  subject(:execute) do
    catch :abort do
      pocket.validate_destroying
    end
  end

  it 'returns self including correct error messages' do
    execute
    expect(handshake.errors.messages[:biscuit]).to include 'is bitten!'
  end
end
```

## 参照
- [6 コールバックの停止](https://railsguides.jp/active_record_callbacks.html#%E3%82%B3%E3%83%BC%E3%83%AB%E3%83%90%E3%83%83%E3%82%AF%E3%81%AE%E5%81%9C%E6%AD%A2)
