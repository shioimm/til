### trailing_slash => true

- URLにtrailing_slashを付与することができる
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
