# ウィンドウサイズを一時的に変更する

```ruby
let(:original) { page.driver.browser.manage.window.size }

before do
  page.driver.browser.manage.window.resize_to(1400, 1400)
end

after do
  page.driver.browser.manage.window.resize_to(original.width, original.height)
end
```
