# ノードへフラグフィールドを追加
## 関数・定数定義
```c
// ビットマスク
#define FOO_START_FLAG      0x01
#define FOO_END_FLAG        0x02
#define FOO_PRIORITY_FLAG   0x04

// ヘッダフィールドハンドル
static int hf_foo_pdu_type   = -1;
static int hf_foo_flags      = -1;
static int hf_foo_sequenceno = -1;
static int hf_foo_initialip  = -1;

// ビットマスクハンドル
static int hf_foo_startflag    = -1;
static int hf_foo_endflag      = -1;
static int hf_foo_priorityflag = -1

// ノードのオープン/クローズ状態を保持するハンドル (ett: epan tree type)
static gint ett_foo = -1;

// ヘッダフィールド定義を格納する配列 (hf: header field)
static hf_register_info hf[] = {
  { &hf_foo_pdu_type, // ノードのインデックス
    { "FOO PDU Type", // 要素のラベル (PDU: Protocol Data Unit / パケット)
      "foo.type",     // 要素の短縮名 (フィルタ用)
      FT_UINT8,       // 要素のタイプ (8ビット符号なし整数)
      BASE_DEC,       // 整数型の扱い (BASE_OCT | BASE_DEC | BASE_HEX)
      NULL,           // 要素のフォーマット (NULL可)
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
  { &hf_foo_startflag,       // フラグフィールドの定義
    { "FOO PDU Start Flags",
      "foo.flags.start",
      FT_BOOLEAN,
      8,
      NULL,
      FOO_START_FLAG,
      NULL,
      HFILL } },
  { &hf_foo_endflag,        // フラグフィールドの定義
    { "FOO PDU End Flags",
      "foo.flags.end",
      FT_BOOLEAN,
      8,
      NULL,
      FOO_END_FLAG,
      NULL,
      HFILL } },
  { &hf_foo_priorityflag,  // フラグフィールドの定義
    { "FOO PDU Priority Flags",
      "foo.flags.priority",
      FT_BOOLEAN,
      8,
      NULL,
      FOO_PRIORITY_FLAG,
      NULL,
      HFILL } },
};

// ビットマスクの並びを定義する配列
static int* const bits[] = {
  &hf_bar_startflag,
  &hf_bar_endflag,
  &hf_bar_priorityflag,
  NULL
};

// パケットの読み込み位置オフセット
gint offset = 0;

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
// フラグフィールドの追加
proto_tree_add_bitmask(
  foo_tree,       // アイテム追加先のツリー (proto_tree *tree)
  tvb,            // パケットデータ (tvbuff_t *tvb)
  offset,         // オフセット (gint offset)
  hf_foo_flags,   // フラグフィールドを示すヘッダフィールドハンドル (static int hf_foo_flags)
  ett_foo,        // ノードのオープン/クローズ状態を保持するハンドル (static gint ett_foo)
  bits,           // ビットマスクの並びを定義する配列 (static int* const bits[])
  ENC_BIG_ENDIAN  // エンコーディング (ENC_NA | ENC_BIG_ENDIAN | ENC_LITTLE_ENDIAN)
);
```

## 参照
- [9.2. Adding a basic dissector](https://www.wireshark.org/docs/wsdg_html_chunked/ChDissectAdd.html)
