# リンク層アドレスの解決と近隣不到達性の検知
- アドレス解決や近隣不到達性検知のためにはマルチキャストを利用する
- マルチキャストが利用可能なネットワークインターフェースが有効になった時点で、
  ノードは全ノードマルチキャストグループに参加するとともに、Solicited-Nodeマルチキャストグループに参加する

## 使用するIPv6メッセージタイプ
#### Neighbor Solicitationメッセージ (近隣要請)
- 同一サブネットに接続している近隣IPv6ノードのリンク層のアドレスを要求すると同時に
  自身のリンク層アドレスを知らせる
  - 近隣ノードとの通信が 不可能になっていないかどうか (近隣不到達性) の検知
  - 同一のIPv6アドレスを利用している他ノードが存在しているかどうか
- リンク層アドレスの解決のために送信される場合はマルチキャストで送信する
- 近隣不到達性検知のために送信される場合は対象となるIPv6ノードを宛先とするユニキャストで送信する

#### Neighbor Advertisementメッセージ (近隣広告)
- Neighbor Solicitationメッセージに対して返答するために送信される
- あるいは設定情報を更新した際、それを即座に伝搬させるために送信される

## 仕組み
1. IPv6アドレスに対応するリンク層アドレスが近隣キャッシュになければ、
   ノードはNeighbor Solicitationメッセージを送信する
   - リンク層アドレスがわからないIPv6パケットの送信がトリガーとなる
   - トリガーとなったIPv6パケット自体は、リンク層アドレスが解決されるまでキューに保存される
2. Neighbor Solicitationメッセージに対し、
   該当するIPv6アドレスが設定されているネットワークインターフェースを持つノードは、
   Neighbor Solicitationメッセージを送信したノードに対して
   ユニキャストでNeighbor Advertisementメッセージを返信する
3. Neighbor AdvertisementメッセージがNeighbor Solicitationメッセージを送信したノードに届くと、
   当該ノードはリンク層アドレスを解決できるようになる

## 近隣キャッシュ
- 近隣ノードのIPv6アドレスとリンク層アドレスの対応づけ
- ノードごとにエントリとして管理される

#### エントリのステート
- INCOMPLETE
  - 該当するエントリに対してアドレス解決が進行中
- REACHABLE
  - 該当するエントリに対応する近隣ノードへ到達可能
- STALE
  - 該当するエントリに対応する近隣ノードは到達可能とはいえない
- DELAY
  - 該当するエントリに対応する近隣ノードは到達可能とはいえないものの
    送出済みのパケットがあり、それを待機している
- PROBE
  - 該当するエントリに対応する近隣ノードの到達性を確認する応答を待っている

## 近隣不到達性検知
- 自ノードから送ったIPv6パケットに対して、それを受け取ったことを知らせる何らかの通知
  (上位層のプロトコルにおける応答かNeighbor Solicitation メッセージに対するNeighbor Advertisement メッセージ)
  を相手ノードから受け取った際、自ノードにとって相手ノードは到達可能であると判断する

## 参照
- プロフェッショナルIPv6 6.3