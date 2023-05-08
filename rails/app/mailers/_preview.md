# ActionMailer::Preview
- メールテンプレートのプレビューを表示する

```ruby
# test/mailers/previews/new_arrivals_nortification_mailer_preview.rb
# localhost:3000/rails/mailers/new_arrivals_nortification_mailer で表示可能

class NewArrivalsNortificationMailerPreview < ActionMailer::Preview
  def notify
    NewArrivalsNortificationMailer.notify
  end
end
```
