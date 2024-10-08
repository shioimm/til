# マッピング
- 内部ネットワークから外部インターネット宛のパケットに含まれる情報をNATルータで変換する際、
  送信元ノードのアドレス・ポート番号を送信先アドレスやポート番号に応じて毎回変化させるか
  (あるいは同じ送信先の場合は毎回同じにするか) を決める方針 (RFC4787)
- RFC4787とRFC5382では、EIMをNAT機器が満たすべき必須の要件としている

#### EIM (Endpoint-Independent Mapping: エンドポイント非依存マッピング)
- 送信先によらず、NAT内部で同一の送信元ノードから発生した通信は
  毎回送信元アドレスとポート番号を同じものに変換する

#### ADM (Address-DependentMapping アドレス依存マッピング)
- 送信先が同じグローバルIPv4アドレスの場合、NAT内部で同一の送信元ノードから発生した通信は
  毎回送信元アドレスとポート番号を同じものに変換する

#### APDM (Address and Port-Dependent Mapping アドレスとポート依存マッピング)
- 送信先が同じグローバルIPv4アドレス・ポート番号の場合、NAT内部で同一の送信元ノードから発生した通信は
  毎回送信元アドレスとポート番号を同じものに変換する

## 参照
- プロフェッショナルIPv6 19.3.1
