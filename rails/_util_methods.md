### `to_json` | `as_json`
- `to_json`
  - オブジェクトをJsonに変換
```ruby
{ hoge: :fuga }.to_json
# =>  "{\"hoge\":\"fuga\"}"
```

- `as_json`
  -  オブジェクトをハッシュロケットを使用したハッシュに変換
```ruby
{ hoge: :fuga }.as_json
# => { "hoge" => "fuga" }
```

#### オプション
- `only:` -> 特定のアトリビュートのみ返す
- `except:` -> 特定のアトリビュートを除いて返す
- `methods:` -> メソッドの呼び出し結果を合わせて返す
- `include:` -> 関連モデルを含めて返す
