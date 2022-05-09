# [参考] packet-drb.c
https://gitlab.com/wireshark/wireshark/-/blob/master/epan/dissectors/packet-drb.c

#### include

```c
#include "config.h"
#include <epan/packet.h>
#include <file-rbm.h>
```

#### 静的変数
```c
static  int proto_drb;
static  int hf_drb_len;
static gint ett_drb;
static gint ett_ref;
```

#### 関数
```c
// レジスタ関数
void
proto_register_drb(void);

// ハンドオフ関数
void
proto_reg_handoff_drb(void);

// ディセクト関数
int
dissect_drb(tvbuff_t* tvb, packet_info* pinfo, proto_tree* tree, void* data _U_);

// guint8 type = tvb_get_guint8(tvb, 6);
//   返り値が'T'または'F'の場合: dissect_drb_response(tvb, pinfo, drb_tree, &offset);
//   それ以外: dissect_drb_request(tvb, pinfo, drb_tree, &offset);

// レスポンスのディセクション
void
dissect_drb_response(tvbuff_t* tvb, packet_info* pinfo, proto_tree* tree, guint* offset);

// リクエストのディセクション
void
dissect_drb_request(tvbuff_t* tvb, packet_info* pinfo, proto_tree* tree, guint* offset)

// オブジェクトのディセクション (詳細)
void
dissect_drb_object(tvbuff_t* tvb, packet_info* pinfo, proto_tree* tree, guint* offset, const gchar* label)
```

#### ユーティリティ

```c
// epan/dissectors/file-rbm.c

// Rubyオブジェクトをディセクトし、カラムに表示を追加する
void
dissect_rbm_object(tvbuff_t* tvb, packet_info* pinfo, proto_tree* ptree, guint* offset, gchar** type, gchar** value)
```
