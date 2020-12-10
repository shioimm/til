# webmock
- 参照: [bblimke/webmock](https://github.com/bblimke/webmock)

## TL;DR
- HTTPリクエストのスタブやレスポンスの返り値を設定するためのライブラリ

## Get Started
```
# Gemfile

gem 'webmock'
```

```ruby
# spec

require 'webmock/rspec'
```

## Usage
```ruby
require 'rails_helper'
require 'webmock/rspec'

describe Api::V1::XxxController, type: :request do
  before do
    WebMock.enable!
  end

  describe 'GET /api/v1/Xxx' do
    before do
      WebMock.stub_request(:get, "http://www.example.com")
            .to_return(status: 200,
                       headers: { 'Content-Type' =>  'application/json' },
                       body: { 'id' => 1 })
    end

    it 'returns 1' do
      expect(JSON.parse(response.body)['id']).to eq 1
    end
  end
end
```
