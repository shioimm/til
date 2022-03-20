# ツリーへテキストを追加
## 関数・定数定義
```c
// パケットタイプ名の定義
static const value_string packettypenames[] = {
  { 1, "Initialise" },
  { 2, "Terminate" },
  { 3, "Data" },
  { 0, NULL }
};

// ディセクタ関数 (パケットのディセクションを行う)
static int dissect_foo(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_);
```

## Wireshark API
#### `static int dissect_foo(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)`
- `tvbuff_t *tvb` - パケットデータとして参照されるバッファ
- `packet_info *pinfo` - プロトコルに関する一般的なデータ
- `proto_tree *tree` - 詳細なディセクションを行うツリー
- `_U_` - パラメータが未使用

```c
guint8 packet_type = tvb_get_guint8(tvb, 0);

proto_item *ti = proto_tree_add_item(tree, proto_bar, tvb, 0, -1, ENC_NA);

// ツリーへテキストを追加
proto_item_append_text(
  ti,                // テキストを追加するツリー (proto_item *ti)
  ", Type %s",       // 追加するテキストのテンプレート
  val_to_str(        // 追加するテキストの値 (val_to_str: 値から文字列を取り出す)
    packet_type,       // guint8 packet_type
    packettypenames,   // パケットタイプ名の定義 (static const value_string packettypenames[])
    "Unknown (0x%02x)" // フォールバック先のテキスト
  )
);
```

## 参照
- [9.2. Adding a basic dissector](https://www.wireshark.org/docs/wsdg_html_chunked/ChDissectAdd.html)
