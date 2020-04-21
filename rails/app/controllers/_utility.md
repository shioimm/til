# Utility
### コントローラーからViewHelperを呼びたい
- `view_context`を使用する
```ruby
view_context.time_ago_in_words(updated_at)
```

### `rescue_from`
- controller内で発生した例外を補足する

#### 使い所
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

### `default_url_options`
- URLにtrailing_slashを付与する
```ruby
class Application < Rails::Application
  config.action_controller.default_url_options = { :trailing_slash => true }
end
```

- 実装はこんな感じ(2019/08/28時点)
```ruby
module ActionDispatch
  module Http
    module URL
      #...
      def path_for(options)
        #...
        add_trailing_slash(path) if options[:trailing_slash]
        #...
      end
      #...
        def add_trailing_slash(path)
          if path.include?("?")
            path.sub!(/\?/, '/\&')
          elsif !path.include?(".")
            path.sub!(/[^\/]\z|\A\z/, '\&/')
          end
        end
```
