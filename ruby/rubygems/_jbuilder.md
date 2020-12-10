# jbuilder

## 代表的な書き方一覧
- 引用元: [rails/jbuilder](https://github.com/rails/jbuilder)

- Jbuilder
```ruby
# app/views/messages/show.json.jbuilder

json.content format_content(@message.content)

# ヘルパーも使える(format_content)
# {
#   "content": "<p>This is <i>serious</i> monkey business</p>"
# }

json.(@message, :created_at, :updated_at)

# {
#   "created_at": "2011-10-29T20:45:28-05:00",
#   "updated_at": "2011-10-29T20:45:28-05:00"
# }

json.author do
  json.name @message.creator.name.familiar
  json.email_address @message.creator.email_address_with_name
  json.url url_for(@message.creator, format: :json)
end

# ブロックの中に書くと入れ子にできる
# {
#   "author": {
#     "name": "David H.",
#     "email_address": "'David Heinemeier Hansson' <david@heinemeierhansson.com>",
#     "url": "http://example.com/users/1-david.json"
#   },
# }

if current_user.admin?
  json.visitors calculate_visitors(@message)
end

# 条件分岐も使える
# {
#   "visitors": 15,
# }

json.comments @message.comments, :content, :created_at

# 複数のレコードが含まれるインスタンス変数は配列として返すことができる
# {
#   "comments": [
#     { "content": "Hello everyone!", "created_at": "2011-10-29T20:45:28-05:00" },
#     { "content": "To you my good sir!", "created_at": "2011-10-29T20:47:28-05:00" }
#   ],
# }

json.attachments @message.attachments do |attachment|
  json.filename attachment.filename
  json.url url_for(attachment)
end

# アソシエーションも複数のレコードが含まれる場合と同じようには配列として返すことができる
# {
#   "attachments": [
#     { "filename": "forecast.xls", "url": "http://example.com/downloads/forecast.xls" },
#     { "filename": "presentation.pdf", "url": "http://example.com/downloads/presentation.pdf" }
#   ]
# }
```

- 上記のコードで生成されるjson
```ruby
{
  "content": "<p>This is <i>serious</i> monkey business</p>",
  "created_at": "2011-10-29T20:45:28-05:00",
  "updated_at": "2011-10-29T20:45:28-05:00",

  "author": {
    "name": "David H.",
    "email_address": "'David Heinemeier Hansson' <david@heinemeierhansson.com>",
    "url": "http://example.com/users/1-david.json"
  },

  "visitors": 15,

  "comments": [
    { "content": "Hello everyone!", "created_at": "2011-10-29T20:45:28-05:00" },
    { "content": "To you my good sir!", "created_at": "2011-10-29T20:47:28-05:00" }
  ],

  "attachments": [
    { "filename": "forecast.xls", "url": "http://example.com/downloads/forecast.xls" },
    { "filename": "presentation.pdf", "url": "http://example.com/downloads/presentation.pdf" }
  ]
}
```
