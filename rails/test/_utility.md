# Utility
## System Specでよく使うメソッド
### 操作系
- `visit`
- `fill_in`
- `select`
- `click_button`
- `click_on`
- `page.driver.browser.switch_to.alert.accept` -> 確認ダイアログでOKを選択
- `page.driver.browser.switch_to.alert.dismiss` -> 確認ダイアログでキャンセルを選択
- `login_as`(ヘルパーとして記述しておく)
```ruby
# spec_helper.rb
def login_as(user)
  visit new_user_session_path
  fill_in 'user_username', with: user.username
  fill_in 'user_password', with: user.password
  click_on 'ログイン'
end
```

### マッチャ系
- `have_content / `have_no_content``
- `have_selector`
- `change`
- `have_enqueued_job`

## 共通化
### `shared_context`
- 実行条件の共通化
```ruby
# spec/support/shared_contexts.rb
# case: テストの実行中、実行時間を当日中に固定したい
shared_context 'with freeze closing time before' do |closing_time|
    before do
    now = Time.zone.now
    closing_time = closing_time
    current_time = closing_time > now ? now : closing_time
    Timecop.freeze(current_time)
  end

  after do
    Timecop.return
  end
end
```
```ruby
# Usage
include_context 'with freeze termination time before', Time.zone.parse("#{Time.zone.today} 23:59")
```

#### `shared_context`をメタデータとして使う
- 参照: [RSpec 3.5 から shared_context の使い方が少し変わっていた](https://masutaka.net/chalow/2017-11-10-2.html)

```ruby
# spec/support/shared_contexts.rb
# case: ログイン状態で操作したい

shared_context 'signin' do
  let(:user) { create(:user) }
  before { signin_as user }
end
```

```ruby
# spec/spec_helper.rb
# メタデータとして使う対象のcontextを設定する

RSpec.configure do |config|
  config.include_context 'signin', :signin
end
```

```ruby
# spec/hoge_spec.rb

context 'with logged in', :signin do
  ...
end
```

### `shared_examples`
- `it`の共通化
```ruby
# spec/support/shared_examples.rb
# case: 正常にレスポンスが返ってきた場合の挙動を定義したい
shared_examples 'returns access is successful' do
  it { is_expected.to be_successful }
  it { is_expected.to have_http_status :ok }
end
```

```ruby
# Usage
it_behaves_like 'returns access is successful'
```
