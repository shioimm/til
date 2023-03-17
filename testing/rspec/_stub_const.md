# `stub_const`
- 定数をスタブ化する

```ruby
class Foo
  BAR = "bar"
end

describe "stubbing" do
  it "returns stubbed value" do
    stub_const("Foo::BAR", true)
    expect(Foo::BAR).to be true # success
  end
end
```
