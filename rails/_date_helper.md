# ActionView::Helpers::DateHelper
#### 経過時間

```ruby
# to
time_ago_in_words(Time.now + 29.seconds) # => less than a minute↲

# from, to
distance_of_time_in_words(Time.now, Time.now + 29.seconds) # => less than a minute
```
