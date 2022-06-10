# 操作系DSL
#### ページを開く
- `visit`

#### クリック
- `click_link`
- `click_button`
- `click_on`

#### フォーム
- `fill_in` (テキスト)
- `select` (セレクタ)
- `choose` (ラジオボタン)
- `check` / `uncheck` (チェックボックス)
- `attach_file` (添付ファイル)

#### ページ内要素の確認・操作
- `page.has_selector?`
- `page.has_css?`
- `page.has_content?`
- `find_field('First Name').value`
- `find_link('Hello', :visible => :all).visible`?
- `find_button('Send').click`
- `find("#overlay").find("h1").click`
- `all('a').each { |a| a[:href] }`

#### ブラウザ操作
- `page.driver.browser.switch_to.alert.accept` -> 確認ダイアログでOKを選択
- `page.driver.browser.switch_to.alert.dismiss` -> 確認ダイアログでキャンセルを選択

#### `login_as`

```ruby
def login_as(user)
  visit new_user_session_path
  fill_in 'user_username', with: user.username
  fill_in 'user_password', with: user.password
  click_on 'Log in'
end
```

## 参照
- [The DSL](https://github.com/teamcapybara/capybara#the-dsl)
