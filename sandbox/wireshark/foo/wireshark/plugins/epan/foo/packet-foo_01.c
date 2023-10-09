// ref: https://www.wireshark.org/docs/wsdg_html_chunked/ChDissectAdd.html

// プロトコルハンドル static int proto_foo
//   プロトコルを参照したりディセクタハンドルを取得するために用いるハンドル
//
// ディセクタハンドル static dissector_handle_t foo_handle;
//   プロトコルとディセクタ関数に関連付けられるハンドル
//
// レジスタルーチン proto_register_foo
//   Wiresharkにプロトコルを登録する
//   Wiresharkの起動時に呼び出される
//
// ハンドオフルーチン proto_reg_handoff_foo(void)
//   プロトコルハンドルとプロトコルのトラフィックを関連付ける
//
// ディセクタ関数 dissect_foo
//   トラフィック時に呼ぶ関数
//     tvb   - パケットが格納されたバッファ
//     pinfo - プロトコルに関する一般的なデータ
//     tree  - パケットの詳細
//     _U_  - パラメータが未使用であることを示す

#include "config.h"
#include <epan/packet.h>

#define FOO_PORT 30000

static int dissect_foo(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree _U_, void *data _U_)
{
  // col_set_str - WiresharkのProtocolカラムを"FOO"に設定
  col_set_str(pinfo->cinfo, COL_PROTOCOL, "FOO");
  // col_clear - INFOカラムのデータを消去
  col_clear(pinfo->cinfo,COL_INFO);

  return tvb_captured_length(tvb);
}

static int proto_foo = -1;

void proto_register_foo(void)
{
  proto_foo = proto_register_protocol(
    "FOO Protocol", // name
    "FOO",          // short name
    "foo"           // filter_name
  );
}

void proto_reg_handoff_foo(void)
{
  static dissector_handle_t foo_handle;

  // Wiresharkがポート30000上のTCPトラフィックを受信するとディセクタ関数dissect_foo()を呼び出す
  foo_handle = create_dissector_handle(dissect_foo, proto_foo);
  dissector_add_uint("tcp.port", FOO_PORT, foo_handle);
}

// wireshark/build/ でビルド ($ cmake .. -> $ make) すると
// run/Wireshark.app/Contents/PlugIns/wireshark/VERSION/epan/内に共有ライブラリが作成される
