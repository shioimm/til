# ノードへパケットタイプ名を表示
## 関数・定数定義
```c
// パケットタイプ名の定義
static const value_string packettypenames[] = {
  { 1, "Initialise" },
  { 2, "Terminate" },
  { 3, "Data" },
  { 0, NULL }
};

// ヘッダフィールド定義を格納する配列 (hf: header field)
static hf_register_info hf[] = {
  { &hf_foo_pdu_type,        // ノードのインデックス
    { "FOO PDU Type",        // 要素のラベル (PDU: Protocol Data Unit / パケット)
      "foo.type",            // 要素の短縮名 (フィルタ用)
      FT_UINT8,              // 要素のタイプ (8ビット符号なし整数)
      BASE_DEC,              // 整数型の扱い (BASE_OCT | BASE_DEC | BASE_HEX)
      VALS(packettypenames), // パケットから取得した数値をパケットタイプ名 (文字列) として表示する
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
```

## Wireshark API
#### `static hf_register_info hf[]`
```c
// 値から文字列を取得する

VALS(packettypenames) // static const value_string packettypenames[]
```

## 参照
- [9.2. Adding a basic dissector](https://www.wireshark.org/docs/wsdg_html_chunked/ChDissectAdd.html)
