# `#inquiry`

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false

languages = [:ruby, :python].inquiry
languages.ruby?                 # => true
languages.c?              # => false
languages.any?(:ruby, :c)  # => true
languages.any?(:c, :cpp)  # => false
```

## 参照
- [5.7 inquiry](https://railsguides.jp/active_support_core_extensions.html#inquiry)
- [inquiry()](https://api.rubyonrails.org/classes/Array.html#method-i-inquiry)
