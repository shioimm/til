# IPv6アドレスのスコープ
- IPv6アドレスの有効範囲

### リンクローカルスコープ
- 対象となるネットワークインターフェースが同一リンク内でのみ一意なIPv6アドレス
- 同じネットワーク上のホストと通信する場合に使用される

### グローバルスコープ
- ネットワークインターフェースをインターネット全体の中で一意に識別できるIPv6アドレス
- IPv4のグローバルアドレスに相当する

## ゾーン
- あるスコープ内のリンクとネットワークインターフェースが属するトポロジ的な範囲
- あるインターフェースが属するゾーンは、同じスコープに対するものであれば、必ずひとつになる
- スコープが異なる場合、複数のゾーンに同じインターフェースが属することがありえる
- ゾーン内のパケットがゾーン外に転送されることは禁止されている
- ゾーンとゾーンの境界はリンク上には存在せず、ノード内に存在する

#### インターフェースローカルスコープの場合
- ノード上の各インターフェースによってひとつのゾーンが形成される
  (マルチキャストの場合のみ)

#### リンクローカルスコープ
- あるリンクとそのリンクに接続されたネットワークインターフェースによってひとつのゾーンが形成される
  (ユニキャスト、エニーキャスト、マルチキャストの場合)

#### グローバルスコープの場合
- インターネットに接続されたすべてのリンクとネットワークインターフェースによってひとつのゾーンが形成される

#### それ以外のスコープ
- ネットワーク管理者によってゾーンが定義され、設定される

### ゾーンインデックス (ゾーンID)
- あるインターフェースにおけるグローバルスコープ以外のアドレスがどのゾーンに属するものかを
  ノード内で一意に識別するために用いられる識別子

```
<address>%<zone_id>
```

## 参照
- プロフェッショナルIPv6 3.3, 3.6