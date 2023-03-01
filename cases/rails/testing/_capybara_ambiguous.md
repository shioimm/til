# `Capybara::Ambiguous`

```ruby
Capybara::Ambiguous:
  Ambiguous match, found 2 elements matching visible css "button" with text "submit"
```

- 同じ画面に重複する要素が存在する
- `match`オプションで該当する要素を一意に特定する

```ruby
find('button', text: 'submit', match: :first).click
```

## 参照
- [Strategy](https://github.com/teamcapybara/capybara#strategy)
