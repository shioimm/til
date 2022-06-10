# スタブ / モック
- スタブ - 指定のメソッドを呼んだ際、本来のメソッドを実行せず、任意の値を返すもの (`allow`)
- モック - 指定のメソッドが実行されたかどうかを引数や頻度を指定してチェックするもの (`expect`)
- スパイ - スタブを利用してモックをチェックするテストの構造

```ruby
let(:xxx_rest_client_instance) { double('Xxx::Rest::Client', to_jwt: 'token') }

before do
  allow(Xxx::Rest::Client).to receive(:new).and_return xxx_rest_client_instance
end

# 以降、xxx_rest_client_instanceに対してto_jwtを呼ぶと'token'を返すようになる
```

- `double` - 返り値の代替となるオブジェクト
  - メソッドの代替として任意の値を返すハッシュを渡すことができる
- `allow` - 対象のオブジェクト・メソッド・返り値を指定する

## 参照
- [Rails tips: RSpecのスタブとモックの違い（翻訳）](https://techracho.bpsinc.jp/hachi8833/2018_04_25/55467)
