# 近隣探索プロトコルで使用するICMPv6メッセージタイプ
#### Router Advertisementメッセージ
- リンク上のホストが自身のアドレスを設定するために必要な情報
- ルータはRouter Advertisementメッセージを定期的にリンク内にマルチキャストする
- サブネット内のノードはRouter Advertisementメッセージからルータを発見する
- サブネット内のノードはRouter Advertisementメッセージに含まれているプレフィクス情報に
  インターフェースIDを加えることでIPv6アドレスを自動生成する (SLAAC)

#### Router Solicitationメッセージ
- ネットワークに接続された各機器からルータに対してRouter Advertisementメッセージの送信を行うように要求する
  - 機器にまだIPv6 アドレスが設定されていない場合は未定義アドレス (`::128`) が送信元 IPv6 アドレスになる

#### Neighbor Solicitationメッセージ
- 同一サブネット内に接続している近隣ノードのリンク層アドレスを得る

#### Neighbor Advertisementメッセージ
- Neighbor Solicitationメッセージに対して返答する

#### Redirectメッセージ
- ルータがホストに対して宛先に対するより最適な次ホップノードを伝える

## 参照
- プロフェッショナルIPv6 6
