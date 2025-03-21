# NTP
- Network Time Protocol
- ネットワークに接続される機器の時刻を同期するためのプロトコル
- 時刻情報を要求するNTPクライアントと時刻情報を提供するNTPサーバーから成るアプリケーション
  - UDPポート123番を使って通信を行う
  - NTPクライアントはNTPサーバーから時刻情報を取得した後、自身の時刻と取得した時刻のずれを修正する

## NTPサーバーが時刻を取得する仕組み
- NTPサーバーはStratumと呼ばれる階層構造を持つ
  - Stratum0 - GPS衛星や原子時計の正確な時刻情報
- NTPサーバーは自身よりも上位のサーバーから時刻を同期し、下位のサーバーへ時刻情報を配信する
- NTPサーバーを設定する際、上位のNTPサーバー (ホスト名) を指定する必要がある

## 参照
- マスタリングTCP/IP 入門編
