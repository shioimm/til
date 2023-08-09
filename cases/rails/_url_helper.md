# ApplicationHelperがincludeされていない箇所でURLヘルパーを使用する

```ruby
include Rails.application.routes.url_helpers

# または

Rails.application.routes.url_helpers.????_url
```
