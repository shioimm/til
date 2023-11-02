# POROのi18n対応
```ruby
# config/application.rb

config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
```

```yml
# config/locales/services/ja.yml

ja:
  articles:
    update_service:
      record_invalid: '更新に失敗しました'
```

```ruby
# app/services/articles/update_service.rb

module Articles
  class UpdateService
    def execute
      raise ActiveRecord::RecordInvalid if invalid_record?

      article.update(article_params)
      true
    rescue ActiveRecord::RecordInvalid => e
      ErrorUtility.logger e
      article.errors.add(:base, I18n.t('.articles.update_service.record_invalid'))
      false
    end
  end
end
```
