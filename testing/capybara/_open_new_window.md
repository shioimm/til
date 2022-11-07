# 新しいウィンドウを開いて操作

```ruby
# 新しいウィンドウを開く
Capybara.open_new_window

# 現在のウィンドウでの操作
# ...

within_window(windows.last) do
  # 新しいウィンドウでの操作
  # ...
end

# 新しいウィンドウを閉じる
Capybara.current_window.close
```

```ruby
# 局所的な操作
Capybara.within_window(Capybara.open_new_window) do
  # ...
end
```
