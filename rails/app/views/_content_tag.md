# `content_tag`
### `tag.<tag name>(name = nil, options = nil, open = false, escape = true)`
#### `<i>`要素を生成したい
- 表示するcontentがないため、第一引数に`''`を使用する
```ruby
h.tag.i('', class: 'fas.fa-pencil-alt.fa-2x')
```
- 参照: [Rails tips: ビューの`content_tag`のあまり知られていないオプション（翻訳）](https://techracho.bpsinc.jp/hachi8833/2018_04_10/54701)
