# Utils
### コントローラー内で発生した例外を補足する
- [`rescue_from`](https://railsguides.jp/action_controller_overview.html#rescue-from)
  - エラー画面をカスタムする
  - ErrorsControllerを作る
```ruby
class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :render_500_error_page

  def render_500_error_page
    render 'errors/500', layout: 'application', status: 500
  end
end
```

### URLにtrailing slashを付与する
- `default_url_options`
```ruby
class Application < Rails::Application
  config.action_controller.default_url_options = { :trailing_slash => true }
end
```

### `ApplicationController`で記述した`http_basic_authenticate_with`を特定のcontrollerでスキップする
#### Before
```ruby
class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV['BASIC_USER'], password: ENV['BASIC_PASSWORD']
end
```

#### After
```ruby
class ApplicationController < ActionController::Base
  before_action :basic_auth_in_staging

  def http_basic_auth
    http_basic_authenticate_or_request_with name: ENV['BASIC_USER'], password: ENV['BASIC_PASSWORD'], realm: nil
  end
end
```

```ruby
class XxxController < ApplicationController
  skip_before_action :basic_auth_in_staging
end
```
