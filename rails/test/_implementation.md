# 実装アイディア集
## メール送信
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

## モデルに依存しないテスト
- Structを使う
```ruby
# カスタムバリデータのテスト
let(:attribute_names) { %i[user_id] }
let(:model_class) {
  example_group = self
  Struct.new(*attribute_names) do
    include ActiveModel::Validations
    validates_with example_group.described_class
  end
}

context 'when user_id is 1' do
  let(:user_id) { 1 }
  subject { model_class.new(user_id) }

  it { is_expected.to be_valid }
end
```

- stub_constを使う
```ruby
let(:klass) { Class.new(described_class) }

it 'works' do
  stub_const('TestClass', klass)
  expect { define_test }.to be_truthy
end
```

### どちらを使うか
- 新しく作ったクラスに任意のattributeを定義したい -> Struct
- 追加でattributeを定義する必要がない -> stub_cons
