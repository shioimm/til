# サブツリーの追加
## 関数・定数定義
```c
// プロトコルハンドル
static int proto_foo = -1;

// ヘッダフィールドハンドル
static int hf_foo_pdu_type   = -1;
static int hf_foo_flags      = -1;
static int hf_foo_sequenceno = -1;
static int hf_foo_initialip  = -1;

// ノードのオープン/クローズ状態を保持するハンドル (ett: epan tree type)
static gint ett_foo = -1;

// ヘッダフィールド定義を格納する配列 (hf: header field)
static hf_register_info hf[] = {
  { &hf_foo_pdu_type, // ノードのインデックス
    { "FOO PDU Type", // 要素のラベル (PDU: Protocol Data Unit / パケット)
      "foo.type",     // 要素の短縮名 (フィルタ用)
      FT_UINT8,       // 要素のタイプ (8ビット符号なし整数)
      BASE_DEC,       // 整数型の扱い (BASE_OCT | BASE_DEC | BASE_HEX)
      NULL,
      0x0,
      NULL,
      HFILL } },
  { &hf_foo_flags,
    { "FOO PDU Flags",
      "foo.flags",
      FT_UINT8,
      BASE_HEX,
      NULL,
      0x0,
      NULL,
      HFILL } },
  { &hf_foo_sequenceno,
    { "FOO PDU Sequence Number",
      "foo.seqn",
      FT_UINT16,
      BASE_DEC,
      NULL,
      0x0,
      NULL,
      HFILL } },
  { &hf_foo_initialip,
    { "FOO PDU Initial IP",
      "foo.initialip",
      FT_IPv4,
      BASE_NONE,
      NULL,
      0x0,
      NULL,
      HFILL } },
};

// 各ノードのオープン/クローズ状態を格納する配列
static gint *ett[] = {
  &ett_foo
};

// パケットの読み込み位置オフセット
gint offset = 0;

// ディセクタ関数 (パケットのディセクションを行う)
static int dissect_foo(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_);

// レジスタ関数 (Wiresharkにプロトコルを登録する)
void proto_register_foo();
```

## Wireshark API
#### `static int dissect_foo(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)`
- `tvbuff_t *tvb` - パケットデータとして参照されるバッファ
- `packet_info *pinfo` - プロトコルに関する一般的なデータ
- `proto_tree *tree` - 詳細なディセクションを行うツリー
- `_U_` - パラメータが未使用

```c
// ツリーに対するアイテムの追加 (返り値はproto_item*)
proto_tree_add_item(
  tree,       // アイテム追加先のツリー (proto_tree *tree)
  proto_foo,  // 追加するアイテムのハンドル (static int proto_foo, hf_foo_pdu_type ...)
  tvb,        // パケットデータ (tvbuff_t *tvb)
  0,          // オフセット
  -1,         // 読み込むパケットデータサイズ (-1: 最後まで)
  ENC_NA      // エンコーディング (ENC_NA | ENC_BIG_ENDIAN | ENC_LITTLE_ENDIAN)
);

// ツリーに対するノードの追加
proto_item_add_subtree(
  ti,     // ノード追加先のツリー (proto_item *ti)
  ett_foo // ノードのオープン/クローズ状態を保持するハンドル
);
```

#### `void proto_register_foo()`
```c
// プロトコルにヘッダフィールド情報を登録する
proto_register_field_array(
  proto_foo,       // プロトコルハンドル (static int proto_foo)
  hf,              // ヘッダフィールド定義を格納する配列 (static hf_register_info hf[])
  array_length(hf) // ヘッダフィールド定義を格納する配列の長さ
);

// プロトコルにノードのオープン/クローズ状態を登録する
proto_register_subtree_array(
  ett,               // ノードのオープン/クローズ状態を格納する配列 (static gint *ett[])
  array_length(ett)  // 配列の長さ
);
```

## 参照
- [9.2. Adding a basic dissector](https://www.wireshark.org/docs/wsdg_html_chunked/ChDissectAdd.html)
