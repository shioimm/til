# vcr
- 参照: [vcr/vcr](https://github.com/vcr/vcr)

## TL;DR
- テスト時、HTTPリクエストに対するインタラクションをローカルに記録することにより、
  次回以降のリクエスト時に参照することを可能にするライブラリ

## Usage
```ruby
# spec/spec_helper.rb

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end
```

```ruby
describe Api::V1::XxxController, type: :request do
  def test_example_dot_com
    VCR.use_cassette("synopsis") do
      response = Net::HTTP.get_response(URI('http://www.iana.org/domains/reserved'))
      assert_match /Example domains/, response.body
    end
  end

  describe 'GET /api/v1/Xxx', { cassette_name: 'xxx_api' } do
    it "returns 1" do
      response = call_xxx_api('http://www.example.com')
      expect(JSON.parse(response.body)['id']).to eq 1
    end
  end
end
```
