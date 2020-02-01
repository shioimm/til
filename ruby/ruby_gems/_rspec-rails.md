# rspec-rails

## マッチャ
### `satisfy`
- 参照: [satisfy matcher](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/satisfy-matcher)
- ブロックの中でsubjectの返り値に対して`true / false`を確認することができる
```ruby
subject { number } # number = 10

is_expected.to satisfy { |v| v.modulo(5).zero? }
is_expected.not_to satisfy { |v| v.modulo(3).zero? }
```

## RSpec固有の概念
### System Spec / Feature Spec
- FeatureからSystemへ移行が必要
- SystemはFeatureに比較して以下の機能をサポートしている
  - テスト終了時に自動的にDBをロールバック(database_cleanerが不要)
  - テスト失敗時のスクリーンショットをデスクトップに保存(capybara-screenshotが不要)
  - スペックごとのブラウザ切り替えが可能(driven_by)

### スタブ / モック
- 参照: [Rails tips: RSpecのスタブとモックの違い（翻訳）](https://techracho.bpsinc.jp/hachi8833/2018_04_25/55467)
- スタブ -> 指定のメソッドを呼んだ際、本来のメソッドを実行せず、欲しい値を返させる(`allow`)
- モック -> 指定のメソッドがテスト中に実行されたかどうかをチェックする(`expect`)
- スタブを利用してモックをチェックするテストの構造をスパイと呼ぶ

### shared_context
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

### shared_examples
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

### `shared_context`をメタデータとして使う
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

## Howto
### 特定のスペックだけ実行する
- 失敗するスペックだけ実行する
```ruby
RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec/examples.'
```
```sh
$ rspec --only-failures
```

- 一回でもテストケースが失敗した時点で終了する
```sh
$ rspec --fail-fast
```

- 指定したスペックだけ実行する
```sh
$ rspec --example '実行したいexample / edescribe名(一部)'
```

- フォーカス中のスペックだけ実行する
```ruby
RSpec.configure do |config|
  config.filter_run focus: true

# 実行したいスペックに`f`をつける
# 実行したくないスペックを除外する場合は対象のスペックに`x`をつける
```

### 出力の変更
- テストを実行せずにテスト一覧を出力
```sh
$ rspec --dry-run
```

- 実行に時間がかかったスペックを出力
```sh
$ rspec --profile
```

### メール送信
- 参照: [RSpec でキューイングした ActiveJob を同期実行する](https://qiita.com/upinetree/items/41a2a8fe9e1dd7c291ab)
```ruby
# config/environments/test.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :test

  # ジョブがキューに入ったことをテストしたい場合
  config.active_job.queue_adapter = :test

  # Sidekiqを使用している場合
  ## ジョブをキューに入れる(デフォルト)
  Sidekiq::Testing.fake!
  ## ジョブをキューに入れずに即時実行する(結果をテストする)
  Sidekiq::Testing.inline!
end
```
```ruby
# spec/rails_helper.rb

RSpec.configure do |config|
  # メールのテスト用のヘルパーを使用する
  config.include emailspec::helpers
  config.include emailspec::matchers

  # ジョブがキューに入ったこととその実行結果を両方テストしたいとき
  # 各exampleに対してactivejob.queue_adapterをActiveJob::QueueAdapter::TestAdapterにする
  config.include ActiveJob::TestHelper
end
```
```ruby
RSpec.describe HogeMailer, type: :mailer do
  after do
    ActionMailer::Base.deliveries.clear
  end

  subject(:send_mail) { described_class.send_notification(hogehoge) }

  let(:user) { create(:user) }

  before do
    user
    # perform_enqueued_jobsはActiveJob::TestHelperのメソッド
    # ジョブを同期実行する
    perform_enqueued_jobs { send_mail }
  end

  # open_email / open_last_emailはEmailSpec::Helpersのメソッド
  it 'is sent to user' do
    expect(open_email(user.email)).to be_delivered_to user
  end

  it 'is sent from catallog' do
    expect(open_last_email).to deliver_from 'from@example.com'
  end

  it 'is sent with correct subject' do
    expect(open_last_email.subject).to include 'hoge'
  end

  it 'is sent with correct body text' do
    expect(open_last_email).to have_body_text 'hoge'
  end
end
```
