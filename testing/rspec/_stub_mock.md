# スタブ / モック
- スタブ - 指定のメソッドを呼んだ際、本来のメソッドを実行せず、任意の値を返すもの (`allow`)
- モック - 指定のメソッドが実行されたかどうかを引数や頻度を指定してチェックするもの (`expect`)
- スパイ - スタブを利用してモックをチェックするテストの構造

```ruby
let(:***_client) { double('***::Client', to_jwt: 'token') }

before do
  allow(:***_client_instance).to receive(:new).and_return '***_client_instance'
end
```

- `double` - 返り値の代替となるオブジェクト
  - メソッドの代替として任意の値を返すハッシュを渡すことができる
- `allow` - 対象のオブジェクト・メソッド・返り値を指定する

## Partial test double
- 実際のクラス・インスタンスを用いたダブル

```ruby
let(:***_client) { double('***::Client', to_jwt: 'token') }

before do
  allow(***::Client).to receive(:new).and_return xxx_rest_client_instance
end
```

## 参照
- [Rails tips: RSpecのスタブとモックの違い（翻訳）](https://techracho.bpsinc.jp/hachi8833/2018_04_25/55467)
- [Partial test doubles](https://relishapp.com/rspec/rspec-mocks/docs/basics/partial-test-doubles)
