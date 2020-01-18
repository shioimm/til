# Cookies
- 参照: [TESTING SIGNED AND ENCRYPTED COOKIES IN RAILS](https://philna.sh/blog/2020/01/15/test-signed-cookies-in-rails/)
- cookiesメソッドでcontrollerから3種類のCookieにアクセスをすることができる
```ruby
cookies['plain'] = 'Kind of simple Cookie'
cookies.signed['signed'] = 'Kind of signed Cookie'
cookies.encrypted['encrypted'] = 'Kind of encrypted Cookie'
```

### `cookies`
- 通常のCookie
- エンドユーザーから読み取り・変更可能
- プレーンテキストによって構成される
- 重要ではないデータを保存する

### `cookies.signed`
- 署名付きCookie
- エンドユーザーは読み取りが可能だが変更不可能
- 「ペイロード-署名」によって構成される
  - ペイロード -> Base 64でエンコードされたデータ
  - 署名 -> アプリケーションのsecret_key_baseとCookie内のデータのHMAC SHA1ダイジェスト
    - Cookieの値が変更された場合、署名は値と一致しなくなり、Railsはnilを返す(`ActiveSupport::MessageVerifier`)

### `cookies.encrypted`
- 暗号化Cookie
- エンドユーザーから読み取り・変更不可能
  - 読み取り・変更にはsecret_key_baseが必要
- Cookie内のデータを暗号化してから署名する(`ActiveSupport::MessageEncryptor`)

### Cookieの値をテストする
```ruby
RSpec.describe XxxController, type: :request do
  it 'returns plain cookies from the response' do
    get xxx_path
    expect(cookies['plain']).to eq('Kind of plain Cookie')
  end

  # 暗号化されたCookieはActionDispatch::Cookies::CookieJarでデコードすることによって値を検証する
  # (requestオブジェクトとcookiesの返り値のハッシュを使用する)
  it 'returns signed cookies from the response' do
    get xxx_path
    jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
    expect(jar.signed['signed']).to eq('Kind of signed Cookie')
  end

  it 'returns encrypted cookies from the response' do
    get xxx_path
    jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
    expect(jar.encrypted['encrypted']).to eq('Kind of encrypted Cookie')
  end
end
```
