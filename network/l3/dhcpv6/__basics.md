# DHCPv6
- ステートレスDHCPv6
- ステートフルDHCPv6
- DHCPv6-PD

## 動作フロー
1. DHCPv6クライアントがSolicit (要請) パケットをマルチキャスト
    - 宛先: ff02::1:2
2. DHCPv6サーバーがAdvertise (広告) パケットを送信
    - 設定情報の送信
3. DHCPv6クライアントがRequest (要求) パケットをマルチキャスト
    - 設定情報の確認
4. DHCPv6サーバーがReply (応答) パケットを送信
    - 設定情報を送信

## 参照
- プロフェッショナルIPv6 8
