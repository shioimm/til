# HEv3での代表的なシナリオ
### 最初の接続試行に進むための条件 (OR)
- 条件A:
  - 何らかの肯定的アドレス応答を受信、
    かつ優先アドレスファミリ (通常IPv6) の肯定・否定応答を受信、
    かつSVCB / HTTPSのサービス情報の肯定・否定応答を受信
- 条件B:
  - 何らかの肯定的アドレス応答を受信、
    かつ他の応答が届かないままResolution Delay (推奨50ms) が経過

## 単純なデュアルスタック環境

```text
# 推定されるHTTPS RRの例

example.com.  3600  IN  HTTPS  1  .  alpn="h3,h2"
```

```text
 Client                    DNS Server
    |    HTTPS?  --->            |
    |     AAAA?  --->            |
    |        A?  --->            |
    |                            |
    |        (30ms delay)        |
    |                            |
    |    <--- HTTPS (no hints)   |
    |    <--- AAAA (2 addresses) |
    |                            |
    | Start w/IPv6               |
    |                            |
    |        (2ms delay)         |
    |                            |
    |    <--- A (2 addresses)    |
    |                            |
    | Update w/IPv6 + IPv4       |
    |                            |
```

1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (アドレスヒントなし) / AAAA応答 (2アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
4. IPv6接続開始
5. 2ms後にA応答 (2アドレス)
6. アドレスリストをIPv6 + IPv4へ更新
7. 250ms後にIPv4接続開始

```text
 Client                    DNS Server
   |    HTTPS?  --->            |
   |     AAAA?  --->            |
   |        A?  --->            |
   |                            |
   |        (30ms delay)        |
   |                            |
   |    <--- HTTPS (no hints)   |
   |    <--- A (2 addresses)    |
   |                            |
   | Set 50ms timer             |
   |                            |
   |        (10ms delay)        |
   |                            |
   |    <--- AAAA (2 addresses) |
   |                            |
   | Start w/IPv6 + IPv4        |
   |                            |
```

1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (アドレスヒントなし) / A応答 (2アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答なし + HTTPS肯定応答 = 条件A成立せず
4. Resolution Delay開始
5. 10ms後にAAAA応答 (2アドレス)
6. 優先アドレスファミリ (IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
    - Resolution Delay終了によって条件Bが成立する前に条件Aが成立
7. アドレスリストをIPv6 + IPv4へ更新してIPv6接続開始
8. 250ms後にIPv4接続開始

```text
 Client                    DNS Server
   |    HTTPS?  --->            |
   |     AAAA?  --->            |
   |        A?  --->            |
   |                            |
   |        (30ms delay)        |
   |                            |
   |    <--- HTTPS (no hints)   |
   |    <--- A (2 addresses)    |
   |                            |
   | Set 50ms timer             |
   |                            |
   |        (50ms delay)        |
   |                            |
   | Start w/IPv4               |
   |                            |
   |        (100ms delay)       |
   |                            |
   |    <--- AAAA (2 addresses) |
   |                            |
   | Update w/IPv6 + IPv4       |
   |                            |
```

1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (アドレスヒントなし) / A応答 (2アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答なし + HTTPS肯定応答 = 条件A成立せず
4. Resolution Delay開始
5. Resolution Delayタイムアウト
6. 何らかの肯定的アドレス応答を受信 + Resolution Delay超過 = 条件B成立
7. IPv4接続開始
8. 100ms後にAAAA応答 (2アドレス)
9. アドレスリストをIPv6 + IPv4へ更新
10. 7から250ms後にIPv6接続開始

```text
 Client                    DNS Server
   |    HTTPS?  --->            |
   |     AAAA?  --->            |
   |        A?  --->            |
   |                            |
   |        (30ms delay)        |
   |                            |
   |    <--- AAAA (2 addresses) |
   |    <--- A (2 addresses)    |
   |                            |
   | Set 50ms timer             |
   |                            |
   |        (10ms delay)        |
   |                            |
   |    <--- HTTPS (no hints)   |
   |                            |
   | Start w/IPv6 + IPv4        |
   |                            |
```

1. HTTPS / AAAA / A をDNS問い合わせ
2. AAAA応答 (2アドレス) / A応答 (2アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答あり + HTTPS肯定あるいは否定応答なし = 条件A成立せず
4. Resolution Delay開始
5. 10ms後にHTTPS応答 (アドレスヒントなし)
6. 優先アドレスファミリ (IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
    - Resolution Delay終了によって条件Bが成立する前に条件Aが成立
7. アドレスリストをIPv6 + IPv4へ更新してIPv6接続開始
    - 優先度順でアドレスを並び替える必要がある
8. 250ms後にIPv4接続開始

```text
 Client                    DNS Server
   |    HTTPS?  --->            |
   |     AAAA?  --->            |
   |        A?  --->            |
   |                            |
   |        (30ms delay)        |
   |                            |
   |    <--- AAAA (2 addresses) |
   |    <--- A (2 addresses)    |
   |                            |
   | Set 50ms timer             |
   |                            |
   |        (50ms delay)        |
   |                            |
   | Start w/IPv6 + IPv4        |
   |                            |
```

1. HTTPS / AAAA / A をDNS問い合わせ
2. AAAA応答 (2アドレス) / A応答 (2アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答あり + HTTPS肯定あるいは否定応答なし = 条件A成立せず
4. Resolution Delay開始
5. Resolution Delayタイムアウト
6. 何らかの肯定的アドレス応答を受信 + Resolution Delay超過 = 条件B成立
7. IPv6接続開始
8. 7から250ms後にIPv4接続開始
    - HTTPS応答次第優先度順でアドレスを並び替える必要がある

#### (shioimm)
- SvcPriority = 0の場合はAliasModeなので同じTargetNameに対してHTTPS再クエリが必要
- TargetName != `.`の場合はTargetNameに対してA/AAAA再クエリが必要

### TargetName != `.`の場合
#### AAAA先着
1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (アドレスヒントなし) -> TargetNameへA/AAAAクエリ / AAAA (HOST宛2件アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
4. HOST宛IPv6接続開始
5. 2ms後にA応答
    - TargetNameのA応答 -> アドレスリストをIPv6 (HOST) + IPv4 (TargetName) へ更新
    - HOSTのA応答 -> アドレスリストをIPv6 (HOST) + IPv4 (HOST) へ更新
6. 250ms後に二つ目の接続開始
    - アドレスリストがIPv6 (HOST) + IPv4 (TargetName) -> TargetName宛IPv4接続
    - アドレスリストがIPv6 (HOST) + IPv4 (HOST) -> HOST宛IPv4接続

#### A先着/10ms後にAAAA応答
1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (アドレスヒントなし) -> TargetNameへA/AAAAクエリ / A応答 (2アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答なし + HTTPS肯定応答 = 条件A成立せず
4. Resolution Delay開始
5. 10ms後に応答
    - TargetNameのAAAA応答 -> 優先アドレスファミリ (IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
    - TargetNameのA応答 -> 優先アドレスファミリ (IPv6) の肯定応答なし + HTTPS肯定応答 = 条件A成立せずRD継続
    - HOSTのAAAA応答 -> 優先アドレスファミリ (IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
6. アドレスリストを更新
    - TargetNameのAAAA応答 -> アドレスリストをIPv6 (TargetName) + IPv4 (HOST) へ更新
    - HOSTのAAAA応答あり -> アドレスリストをIPv6 (HOST) + IPv4 (HOST) へ更新
7. IPv6接続開始
    - アドレスリストがIPv6 (TargetName) + IPv4 (HOST) -> TargetName宛IPv6接続
    - アドレスリストがIPv6 (HOST) + IPv4 (HOST) -> HOST宛IPv6接続
8. 250ms後にIPv4接続開始
    - 7-8の間にTargetNameのA応答あり -> TargetName宛のIPv4接続を開始する
    - 7-8の間にTargetNameのA応答なし -> HOST宛のIPv4接続を開始する

#### A先着/Resolution Delayタイムアウト
1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (アドレスヒントなし) -> TargetNameへA/AAAAクエリ / A応答 (2アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答なし + HTTPS肯定応答 = 条件A成立せず
4. Resolution Delay開始
5. Resolution Delayタイムアウト
6. 何らかの肯定的アドレス応答を受信 + Resolution Delay超過 = 条件B成立
7. HOST宛IPv4接続開始
8. 7から100ms後に応答
    - TargetNameのAAAA応答 -> アドレスリストをIPv6 (TargetName) + IPv4 (HOST) へ更新
    - TargetNameのA応答 -> アドレスリストをIPv4 (TargetName) + IPv4 (HOST) へ更新
    - HOSTのAAAA応答 -> アドレスリストをIPv6 (HOST) + IPv4 (HOST) へ更新
9. 7から250ms後に接続開始
    - アドレスリストがIPv6 (TargetName) + IPv4 (HOST) -> TargetName宛IPv6接続
    - アドレスリストがIPv4 (TargetName) + IPv4 (HOST) -> TargetName宛IPv4接続
    - アドレスリストがIPv6 (HOST) + IPv4 (HOST) -> HOST宛IPv6接続

## SVCBヒントによって早期に応答が得られる場合

```text
 Client                    DNS Server
   |    HTTPS?  --->            |
   |     AAAA?  --->            |
   |        A?  --->            |
   |                            |
   |        (30ms delay)        |
   |                            |
   |    <--- HTTPS (w/hints)    |
   |                            |
   | Start w/IPv6 + IPv4        |
   |                            |
```

```text
# 推定されるHTTPS RRの例

example.com. 3600 IN HTTPS 1 . alpn="h3,h2" ipv6hint=2001:db8::1,2001:db8::2 ipv4hint=192.0.2.1,192.0.2.2
```

1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (IPv4/IPv6アドレスヒントあり)
3. 優先アドレスファミリ (IPv6アドレスヒント) の肯定応答 + HTTPS肯定応答 = 条件A成立
4. IPv6アドレスヒント宛にIPv6接続開始
5. 4から250ms後、IPv4アドレスヒント宛にIPv4接続開始

### TargetName != `.`の場合
1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (IPv4/IPv6アドレスヒントあり) -> TargetNameへA/AAAAクエリ
3. 優先アドレスファミリ (IPv6アドレスヒント) の肯定応答 + HTTPS肯定応答 = 条件A成立
4. IPv6アドレスヒント宛にIPv6接続開始
5. 4から250ms後
    - TargetNameへのA応答があった場合
      - -> アドレスリストをIPv6 (アドレスヒント) + IPv4 (TargetName) へ更新
      - -> TargetName宛IPv4接続開始
    - TargetNameへのAAAA応答があった場合
      - -> アドレスリストをIPv6 (TargetName) + IPv4 (アドレスヒント) へ更新
      - -> アドレスヒント宛IPv4接続開始
    - HOSTへのA応答があった場合
      - -> アドレスリストをIPv6 (アドレスヒント) + IPv4 (アドレスヒント) + IPv4 (HOST) へ更新
      - -> アドレスヒント宛IPv4接続開始
    - HOSTへのAAAA応答があった場合
      - -> アドレスリストをIPv6 (アドレスヒント) + IPv4 (アドレスヒント) + IPv6 (HOST) へ更新
      - -> アドレスヒント宛IPv4接続開始
    - 応答がなかった場合 -> アドレスヒント宛IPv4接続開始

## SVCB/HTTPSが複数のサービス名を返す場合

```text
 Client                    DNS Server
    |    HTTPS?  --->            |
    |     AAAA?  --->            |
    |        A?  --->            |
    |                            |
    |        (30ms delay)        |
    |                            |
    |    <--- HTTPS (".")        |
    |    <--- HTTPS ("alt")      |
    |    <--- AAAA (2 addresses) |
    |    <--- A (2 addresses)    |
    |                            |
    | Start w/IPv6 + IPv4        |
    |                            |
    |     AAAA? ("alt")  --->    |
    |        A? ("alt")  --->    |
    |                            |
    |        (30ms delay)        |
    |                            |
    |    <--- AAAA (1 address)   |
    |    <--- A (1 address)      |
    |                            |
    | Update w/IPv6 + IPv4        |
    |                            |
```

## SVCB応答が遅延する場合 (IPv4接続のみ)

```text
 Client                    DNS Server
      |    HTTPS?  --->            |
      |        A?  --->            |
      |                            |
      |        (30ms delay)        |
      |                            |
      |    <--- A (2 addresses)    |
      |                            |
      | Set 50ms timer             |
      |                            |
      |        (10ms delay)        |
      |                            |
      |    <--- HTTPS (no hints)   |
      |                            |
      | Start w/IPv4               |
      |                            |
```
