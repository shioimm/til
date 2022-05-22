# 案
```ruby
WSProtocol.configure(PROTOCOL_NAME) do |config|
  config.transport PROTOCOL    # default: :tcp
  config.port      PORT_NUMBER # default: 3000
  config.filter    FILTER_NAME # default: PROTOCOL_NAME.downcase

  config.fields({
                  label:   HF_LABEL,
                  filter:  HF_FILTER_NAME, # default: FILTER_NAME.downcase + HF_LABEL.downcase.
                  type:    HF_TYPE,
                  display: HF_DISPLAY,
                  size:    HF_SIZE,
                  offset:  HF_OFFSET, # default: nil
                  desc:    HF_DESC,   # default: nil
                })

  # WIP
end
```

```ruby
class WSProtocol
  def initialize
    @name          # String
    @transport     # Symbol
    @port          # Integer
    @filter_name   # String
    @header_fields # Array
  end

  def fields
    @header_fields << {}
  end
end
```

### サポートする機能
- (Ruby) パケット内のヘッダフィールドの種類を設定することができる
  - (C) ヘッダフィールドの種類をhfハンドルで再現する
  - (Ruby) バイナリデータを特定の値に変換するフォーマットを設定することができる
    - (C) フォーマットを`value_string`配列として再現する
- (Ruby) パケット内のツリー構造をネストで表現することができる
  - (C) ツリー構造をディセクタ関数内で再現する
  - (C) ツリー構造に応じてettを利用する
- (Ruby) ツリー内の各ノードを設定することができる
  - (Ruby) ノード前方にoffsetを指定することができる
  - (Ruby) 固定値のデータサイズ (offset) を指定することができる
  - (Ruby) 指定したパケット位置のデータの値に応じて可変値でデータサイズ (offset) を指定することができる
  - (Ruby) 固定値のヘッダフィールドの種類を指定することができる
  - (Ruby) 指定したパケット位置のデータの値に応じて可変値でヘッダフィールドの種類を指定することができる
  - (Ruby) 指定したパケット位置のデータの値に応じてデータ表現方法を指定することができる
    - デフォルトは`proto_tree_add_item`
    - 可変なデータ表現方法としては一旦`proto_tree_add_int_format_value`のみサポートする
    - (Ruby) 任意のRubyスクリプトを渡すことができる

#### 現時点ではサポートしない機能
- ビットフィールド
- `col_add_fstr`
- `proto_item_append_text`
- epanでの登録
- 複数プラグインの登録
