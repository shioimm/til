# NDP (Neighbor Discovery Protocol: 近隣探索プロトコル)
- IPv4におけるARPとICMPリダイレクト、ICMPルータ選択メッセージ、
  IPアドレスの自動設定 (SLAAC) などの機能を提供する
- ICMPv6の近隣探索メッセージを組み合わせて利用し、それぞれのICMPv6メッセージが運ぶオプションデータによって
  さまざまな機能を実現する

#### 使用されるICMPv6の近隣探索メッセージ
- Router Advertisement メッセージ (ルータ広告)
- Router Solicitation メッセージ (ルータ要請)
- Neighbor Solicitation メッセージ (近隣要請)
- Neighbor Advertisement メッセージ (近隣広告)
- Redirectメッセージ

## 機能
- Router Discovery - リンク上のルータを探す
- Prefix Discovery - ルータを経由せずに到達できるIPv6アドレスの範囲を知る
- Parameter Discovery - リンクのMTUなどの情報を知る
- Address Autoconfiguration - インターフェースに対してステートレスにアドレスを割り当てる
- Address Resolution - IPv6 アドレスからリンク層のアドレスを解決する
- Next-hop Determination - 宛先アドレスをもとに、次にパケットを送出すべきIPv6アドレスを知る
- Neighbor Unreachability Detection - 近隣ノードに到達できなくなったことを知る近隣不到達性検知
- Duplicate Address Detection - 利用するアドレスが他のノードで使われていないかを確認する
- Redirect - ルータからホストへ、より適切な送出先を伝える

## 参照
- Linuxプログラミングインターフェース 58章
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 2.8-9
- Linuxで動かしながら学ぶTCP/IPネットワーク入門 4.5
- コンピュータネットワーク
- マスタリングTCP/IP 入門編
- パケットキャプチャの教科書
