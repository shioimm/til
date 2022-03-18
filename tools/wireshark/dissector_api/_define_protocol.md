# プロトコル定義
## 自作関数
```c
// プロトコルハンドル
static int proto_foo = -1;

// ディセクタハンドル
static dissector_handle_t foo_handle;

// レジスタ関数 (Wiresharkにプロトコルを登録する)
void proto_register_foo();

// ハンドオフ関数 (プロトコルとトラフィックを関連づける)
void proto_reg_handoff_foo():

// ディセクタ関数 (パケットのディセクションを行う)
static int dissect_foo(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_);
```

## Wireshark API
#### `void proto_register_foo()`

```c
// プロトコルの登録 (返り値をプロトコルハンドルに格納する)
proto_register_protocol(
  "FOO Protocol", // パケット詳細に表示するプロトコル名
  "FOO",          // パケット一覧 (Protocolカラム) に表示するプロトコル名
  "foo"           // フィルターとして使用するプロトコル名
);
```

#### `void proto_reg_handoff_foo()`

```c
// ディセクタハンドルの作成 (プロトコルとディセクタハンドルの関連付け)
create_dissector_handle(
  dissect_foo, // ディセクタハンドル
  proto_foo    // プロトコルハンドル
);

// ディセクタハンドラ関数の登録 (トラフィックとディセクタハンドルの関連付け)
dissector_add_uint(
  "tcp.port", // ポートの種類
  30000,      // ポート番号
  foo_handle  // ディセクタハンドル (ディセクタ関数 (dissect_foo()) と関連付けられる)
);
```

#### `static int dissect_foo(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)`
- `tvbuff_t *tvb` - パケットデータとして参照されるバッファ
- `packet_info *pinfo` - プロトコルに関する一般的なデータ
- `proto_tree *tree` - 詳細なディセクションを行うツリー
- `_U_` - パラメータが未使用

```c
// パケット一覧画面のカラムにデータをセット
col_set_str(
  pinfo->cinfo, // カラムのフォーマット情報
  COL_PROTOCOL, // 対象のカラム名 (Protocol)
  "FOO"         // カラムにセットするデータ (Protocolカラムに表示するプロトコル名)
);

// パケット一覧画面のカラムのデータをクリア
col_clear(
  pinfo->cinfo, // カラムのフォーマット情報
  COL_INFO      // 対象のカラム名 (Info)
);

// キャプチャされたパケットのサイズを返す (frame.cap_len フィールド)
tvb_captured_length(tvb);
```

## 参照
- [9.2. Adding a basic dissector](https://www.wireshark.org/docs/wsdg_html_chunked/ChDissectAdd.html)
- [Wireshark-dev: Re: [Wireshark-dev] `tvb_captured_length` or `tvb_reported_length?`](https://www.wireshark.org/lists/wireshark-dev/201509/msg00016.html)
