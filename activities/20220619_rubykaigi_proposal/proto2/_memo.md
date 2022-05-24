# 案
```ruby
WSProtocol.configure(PROTOCOL_NAME) do |config|
  config.transport PROTOCOL    # default: :tcp
  config.port      PORT_NUMBER # default: 3000
  config.filter    FILTER_NAME # default: PROTOCOL_NAME.downcase

  config.field name:      HF_NAME,
               label:     HF_LABEL,
               filter:    HF_FILTER_NAME,  # default: FILTER_NAME.downcase + HF_LABEL.downcase.
               cap_type:  HF_CAPTURE_TYPE,
               disp_type: HF_DISPLAY_TYPE,
               desc:      HF_DESCRIPTION,  # default: nil

  config.tree do |t|
    t.node [
             { field:  HF_NAME,
               size:   NODE_SIZE,           # proto_tree_add_itemに渡す
               offset: NODE_OFFSET,
               endian: NODE_ENDIAN_TYPE,    # default: WSTree::ENDIAN_NA
               format: { type: NODE_FORMAT, # default: WSTree::FORMAT_ADD_ITEM
                         value: proc { ... } } }
           ]

    t.subtree(SUBTREE_NAME) do |st|
      st.node [
                { field:  HF_NAME,
                  size:   N_SIZE,           # proto_tree_add_itemに渡す
                  offset: N_OFFSET,
                  endian: N_ENDIAN_TYPE,    # default: WSTree::ENDIAN_NA
                  format: { type: N_FORMAT, # default: WSTree::FORMAT_ADD_ITEM
                            value: proc { ... } } }
              ]
    end
  end
end
```

```ruby
class WSProtocol
  # @name          String
  # @transport     Symbol
  # @port          Integer
  # @filter_name   String
  # @header_fields Array

  def self.configure(name, &block)
    block.call self.new(name)
  end

  def field(f)
    @header_fields << f
  end

  def tree(&block)
    block.call WSTree.new
  end
end

class WSTree
  # @name  String | nil
  # @nodes Array

  def node(items)
    @nodes << items
  end

  def subtree(name, &block)
    block.call self.class.new(name)
  end

  def value_at(position, byte)
    # tvb_get_guint
  end

  def step(byte)
    # offset +=
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
  - (Ruby) 固定値のデータサイズ (offset) を指定することができる
  - (Ruby) 指定したパケット位置のデータの値に応じて可変値でデータサイズ (offset) を指定することができる
  - (Ruby) 固定値のヘッダフィールドの種類を指定することができる
  - (Ruby) 指定したパケット位置のデータの値に応じて可変値でヘッダフィールドの種類を指定することができる
  - (Ruby) 指定したパケット位置のデータの値に応じてデータ表現方法を指定することができる
    - デフォルトは`proto_tree_add_item`
    - 可変なデータ表現方法としては一旦`proto_tree_add_int_format_value`のみサポートする
    - (Ruby) 任意のRubyスクリプトを渡すことができる
  - (Ruby) ノード前方にoffsetを指定することができる

#### 現時点ではサポートしない機能
- ビットフィールド
- `col_add_fstr`
- `proto_item_append_text`
- epanでの登録
- 複数プラグインの登録
