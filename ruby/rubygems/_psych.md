# psych.md
- yamlのバックエンドライブラリ (YAMLのパースと出力を行う)

```ruby
require 'psych'
Psych.load("--- foo") # YAMLをパース => "foo"
Psych.dump("foo: 1")  # YAMLを出力   => "--- 'foo: 1'\n"
```

## 参照
- [library psych](https://docs.ruby-lang.org/ja/latest/library/psych.html)
