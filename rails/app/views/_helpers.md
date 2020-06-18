# ヘルパー
- 参照: [Ruby on Rails master@49baf09 RDOC_MAIN.rdoc](https://edgeapi.rubyonrails.org/)

## `tag.<tag name>(name = nil, options = nil, open = false, escape = true)`
### `<i>`要素を生成したい
- 表示するcontentがないため、第一引数に`''`を使用する
```ruby
h.tag.i('', class: 'fas.fa-pencil-alt.fa-2x')
```
- 参照: [Rails tips: ビューの`content_tag`のあまり知られていないオプション（翻訳）](https://techracho.bpsinc.jp/hachi8833/2018_04_10/54701)

## `form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)`
### フォーム送信後に画面がレンダリングされない
- レコードの生成失敗時、`render :(テンプレート)`を実行しようとした際に発生
- Ajaxを使用しないフォーム送信
- エラーは無く、ログ上ではレンダリングが実行されている
- -> `form_with`ではデフォルトでAjaxを使用するため、オプション`local: true`の追記が必要

## `simple_format(text, html_options = {}, options = {})`
### オプション
- `:sanitize`(bool) -> テキストをサニタイズする(デフォルトはtrue)
- `:wrapper_tag`(string/symbol) -> テキストをラップするHTMLタグを指定する(デフォルトは\<p\>)

### タグを変更する
```ruby
= simple_format @memo, {}, wrapper_tag: 'div'
```
