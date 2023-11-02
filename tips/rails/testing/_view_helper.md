# テストからViewHelperを呼びたい
- ActionView::Helpersモジュールをincludeする

```ruby
require 'rails_helper'

describe Api::V1::UpdatedPricesController, type: :request do
  describe 'GET /api/v1/updated_prices' do
    subject(:get_request) { get api_v1_updated_prices_path }

    include ActionView::Helpers::DateHelper

    let(:updated_price) { create(:updated_price) }

    it 'returns value' do
      expect(JSON.parse(response.body)).to include time_ago_in_words(updated_prices.updated_at)
    end
  end
end
```
