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
