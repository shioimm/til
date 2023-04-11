# NDP (Neighbor Discovery Protocol: 近隣探索プロトコル)
- IPv4のARPとICMPリダイレクト、ICMPルーター選択メッセージ、
  IPアドレスの自動設定などの機能 (DHCPv6と併用する) を提供する
- ICMPv6メッセージのオプションデータを利用する

#### 機能
- Router Discovery - リンク上のルータを探す
- Prefix Discovery - ルータを経由せずに到達できるIPv6アドレスの範囲を知る
- Parameter Discovery - リンクのMTUなどの情報を知る
- Address Autoconfiguration - インターフェースに対してステートレスにアドレスを割り当てる
- Address Resolution - IPv6 アドレスからリンク層のアドレスを解決する
- Next-hop Determination - 宛先アドレスをもとに、次にパケットを送出すべきIPv6アドレスを知る
- Neighbor Unreachability Detection - 近隣ノードに到達できなくなったことを知る近隣不到達性検知
- Duplicate Address Detection - 利用するアドレスが他のノードで使われていないかを確認する
- Redirect - ルータからホストへ、より適切な送出先を伝える

#### 使用するICMPv6メッセージタイプ
- Router Advertisementメッセージ
  - ルータがRouter Advertisementメッセージを定期的にリンク内にマルチキャストすることにより
    サブネット内のノードに自身の存在を通知する
- Router Solicitationメッセージ
  - Router Advertisementメッセージの送信をただちに行うように要求する
- Neighbor Solicitationメッセージ
  - 同一サブネット内に接続している近隣ノードのリンク層アドレスを得る
- Neighbor Advertisementメッセージ
  - Neighbor Solicitationメッセージに対して返答する
- Redirectメッセージ
  - ルータがホストに対して宛先に対するより最適な次ホップノードを伝える

#### 仕組み
1. 送信元ノードがEthernet上で近隣要請メッセージをマルチキャストする
  - 近隣要請メッセージはIPv6のマルチキャストアドレス (ff00::/8) を使用して送信される
2. マルチキャストの対象ノードがパケットを受信し、自身のIPアドレスを調べる
3. 対象のノードが近隣告知メッセージに自身のMACアドレスを格納し返送する
4. 送信元ノードは対象のノードが該当するIPアドレスとMACアドレスと紐づいていることを知る
  - IPアドレスとMACアドレスの対応関係はノードの近隣キャッシュに数分間キャッシュされる

## 参照
- Linuxプログラミングインターフェース 58章
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 2.8-9
- Linuxで動かしながら学ぶTCP/IPネットワーク入門 4.5
- コンピュータネットワーク
- マスタリングTCP/IP 入門編
- パケットキャプチャの教科書
