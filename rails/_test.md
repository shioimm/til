## モデルに依存しないテストの書き方
rspecの場合

#### Structを使う
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

#### stub_constを使う
```ruby
let(:klass) { Class.new(described_class) }

it 'works' do
  stub_const('TestClass', klass)
  expect { define_test }.to be_truthy
end
```

#### どちらを使うか
- 新しく作ったクラスに任意のattributeを定義したい -> Struct
- 追加でattributeを定義する必要がない -> stub_const

## shared_context / shared_examples
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
