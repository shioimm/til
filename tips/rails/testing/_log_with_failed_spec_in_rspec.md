# テスト失敗時にログを出力

```ruby
describe "test" do
  it "outputs logs" do
    expect(something).to be_truthy
  rescue SpecExpectationNotMetError => e
     puts "\nSpecExpectationNotMetError: #{e.message}"
     raise
  end
end
```
