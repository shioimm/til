# YAMLフォーマット

```yml
# ["foo", "bar", ["baz"]]
- foo
- bar
-
  - baz

# { "FOO" => "foo", "BAR" => { "X" => "x" }, "BAZ" => [{ "Y" => "y" }] }
FOO: foo
BAR:
  X: x
BAZ:
  - Y: y
```

## 複数行

```yml
# { "foo": "bar\nbaz\n" }
foo: |
  bar
  baz

# { "foo": "bar\nbaz" }
foo: |-
  bar
  baz

# { "foo": "bar baz\n" }
foo: >
  bar
  baz
```

## アンカー - エイリアス

```yml
foo: &anchor # &<アンカー名>
  foo

# { "bar" => "foo" }
bar:
  <<*anchor # <<*<アンカー名>
```

## 参照
- https://prograshi.com/language/json/what-are-yaml-and-yml/
