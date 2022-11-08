# Rails::Html::SafeListSanitizer
- HTML/CSSをサニタイズする

```ruby
# HTMLをサニタイズする際のセーフリストを設定する
Rails::Html::SafeListSanitizer.allowed_attributes = %w(id class style)
```

## 参照
- [flavorjones/loofah](github.com/flavorjones/loofah/blob/master/lib/loofah/html5/safelist.rb)
- [Class: Rails::Html::SafeListSanitizer](https://www.rubydoc.info/gems/rails-html-sanitizer/Rails/Html/SafeListSanitizer)
