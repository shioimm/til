# `simple_format`
### オプション
- `:sanitize`(bool) -> テキストをサニタイズする(デフォルトはtrue)
- `:wrapper_tag`(string/symbol) -> テキストをラップするHTMLタグを指定する(デフォルトは\<p\>)

### タグを変更する
```ruby
= simple_format @memo, {}, wrapper_tag: 'div'
```

### simple_format内で特定のURLのエスケープを回避する
```haml
= simple_format note.body_with_nonescaped_link
```
```ruby
class Note
  URL_REGEXP = %r{https:\/\/example\.com\/[^\s]+}

  def body_with_nonescaped_link
    matched_urls = body.split
                       .each_with_object([]) { |url, arr| arr << url[URL_REGEXP] if url.match?(URL_REGEXP) }
                       .uniq

    if matched_urls.any?
      matched_urls.each do |matched_url|
        body.gsub!(matched_url, (h.link_to matched_url, matched_url))
      end
    end

    body
  end
end
```

#### リンク押下時に新しいウィンドウを開く
```haml
= simple_format user.user_note.decorate.body_with_hangouts_meet_link, {}, sanitize: false
```
```ruby
class Note
  URL_REGEXP = %r{https:\/\/example\.com\/[^\s]+}

  def body_with_nonescaped_link
    matched_urls = body.split
                       .each_with_object([]) { |url, arr| arr << url[URL_REGEXP] if url.match?(URL_REGEXP) }
                       .uniq

    if matched_urls.any?
      matched_urls.each do |matched_url|
        body.gsub!(matched_url, (h.link_to matched_url, matched_url, target: :_blank, rel: :noopener))
      end
    end

    h.sanitize(body, attributes: %w[href target])
  end
  end
end
```
