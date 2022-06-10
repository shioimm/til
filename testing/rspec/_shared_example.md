# `shared_examples`
- specの共通化

```ruby
# spec/support/shared_examples.rb

# 正常にレスポンスが返ってきた場合の挙動を定義したい
shared_examples 'returns access is successful' do
  it { is_expected.to be_successful }
  it { is_expected.to have_http_status :ok }
end
```

```ruby
# Usage

it_behaves_like 'returns access is successful'
```
