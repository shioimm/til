# IPv6
- [Migrate to IPv6](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-migrate-ipv6.html)
1. VPCにIPv6 CIDRブロックを追加 (VPC > VPC)
2. サブネットにIPv6 CIDRブロックを関連付ける (VPC > サブネット)
3. ルーティングテーブルの経路に`::/0`を追加する (VPC > ルートテーブル)
4. セキュリティグループのルールを更新する (VPC > セキュリティグループ)
5. EC2インスタンスにIPv6アドレスをアサインする (EC2 > インスタンス)
