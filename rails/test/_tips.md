# Tips
## System Spec / Feature Spec
- FeatureからSystemへ移行が必要
- SystemはFeatureに比較して以下の機能をサポートしている
  - テスト終了時に自動的にDBをロールバック(database_cleanerが不要)
  - テスト失敗時のスクリーンショットをデスクトップに保存(capybara-screenshotが不要)
  - スペックごとのブラウザ切り替えが可能(driven_by)

## スタブ / モック
- 参照: [Rails tips: RSpecのスタブとモックの違い（翻訳）](https://techracho.bpsinc.jp/hachi8833/2018_04_25/55467)
- スタブ -> 指定のメソッドを呼んだ際、本来のメソッドを実行せず、欲しい値を返させる(`allow`)
- モック -> 指定のメソッドがテスト中に実行されたかどうかをチェックする(`expect`)
- スタブを利用してモックをチェックするテストの構造をスパイと呼ぶ

## shared_context
- 条件を共通化したいときに使う

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

## shared_examples
- 振る舞いを共通化したいときに使う

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

## `shared_context`をメタデータとして使う
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
