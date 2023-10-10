-- 参照:
-- WiresharkのDissectorを使った独自プロトコル解析をやさしく解説してみました
-- https://io.cyberdefense.jp/entry/wireshark_lua_original_dissector

-- プロトコル定義
-- Proto(プロトコルの名称, プロトコルの概要)
proto = Proto("original", "独自プロトコル")

-- フィルタの対象となるプロトコルフィールドの定義
-- ProtoField.new(プロトコルフィールドの名称, フィルタ名, 型式)
original_size_F = ProtoField.new("独自プロトコルのサイズ", "original.original_size", ftypes.UINT32)
original_data_F = ProtoField.new("独自プロトコルのデータ", "original.original_data", ftypes.STRING)

-- フィルタ、pinfo表示の対象となるプロトコルフィールドをプロトコルフィールド配列へ登録
proto.fields = { original_size_F, original_data_F }

-- Dissector定義
-- dissector(buffer, pinfo, tree)
--  buffer - パケット全体のうち独自プロトコル以降のデータ
--  pinfo  - パケットインフォメーション
--  tree   - パケット詳細部
function proto.dissector(buffer, pinfo, tree)
  -- pinfoのprotocolヘッダに表示する名称を設定
  pinfo.cols.protocol = "ORIGINAL"

  -- パケット詳細部のツリーに表示する内容を定義
  -- *:add(プロトコルフィールド定義, バッファ範囲, ツリー表示内容)
  --   プロトコルフィールド定義を指定すると、フィルタ指定、カラム登録が可能となる
  --   バッファ範囲を指定すると、ツリーを選択した際、該当データbyte部分を反転表示する
  --   ツリー表示内容を指定すると、バッファ範囲の内容に関わらずツリー表示内容が表示される

  -- サブツリーとしてproto (original) を追加、protoのフォーマットbufferを表示
  local subtree = tree:add(proto, buffer())

  -- proto(original) サブツリーにoriginal_size_Fを追加
  -- bufferの0byte目から4byte分をoriginal_size_Fのフォーマットで表示
  subtree:add(original_size_F, buffer(0, 4))

  -- proto(original) サブツリーに original_data_Fを追加
  -- bufferの4byte目から4byte分をoriginal_data_Fのフォーマットで表示
  subtree:add(original_data_F, buffer(4, 4))
end

-- 定義したプロトコルProto:originalをTCPポート番号を指定して既存のTCPのDissectorに紐づける
tcp_table = DissectorTable.get("tcp.port") -- 既存のTCP dissector
tcp_table:add(30000, proto) -- 既存のTCP dissectorにproto(Proto:original)を紐付け

-- 00000008 576f6f6f (サイズ: 8 / データ: Wooo)
-- [0x00, 0x00, 0x00, 0x08, 0x57, 0x6f, 0x6f, 0x6f].pack("C*") をソケットに書き込む
