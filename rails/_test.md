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
- 追加でattributeを定義する必要がない -> stub_cons
