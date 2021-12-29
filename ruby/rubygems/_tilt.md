# tilt
- テンプレートエンジンのための汎用インターフェース
- 複数のテンプレートエンジンを扱うアプリケーションでテンプレートの書き方を統一できて便利

```html
<%#= tilt.erb %>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title><%= @title %></title>
  </head>
  <body>
    <h1><%= @message %></h1>
  </body>
</html>
```

```
$ irb --simple-prompt
>> require 'tilt'
>> require 'erb'
>> @title   = 'Sample'
>> @message = 'This is sample of tilt'
>>
>> template = Tilt.new('tilt.erb') # => #<Tilt::ErubiTemplate:0x00007ffb06927a08
>> output = template.render(self)  # => "<!DOCTYPE html>\n<html>\n  <head>\n    <meta charset=\"utf-8\">\n    <title>Hello, world.</title>\n  </hea...
>>
>> puts output
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Sample</title>
  </head>
  <body>
    <h1>This is sample of tilt</h1>
  </body>
</html>
=> nil
```

## 参照
- [rtomayko/tilt](https://github.com/rtomayko/tilt)
