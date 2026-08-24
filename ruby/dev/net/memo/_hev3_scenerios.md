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
3. 優先アドレスファミリ (HOST宛IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
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
6. 優先アドレスファミリ (HOST宛IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
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
3. 優先アドレスファミリ (HOST宛IPv6) の肯定応答あり + HTTPS肯定あるいは否定応答なし = 条件A成立せず
4. Resolution Delay開始
5. 10ms後にHTTPS応答 (アドレスヒントなし)
6. 優先アドレスファミリ (HOST宛IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
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
3. 優先アドレスファミリ (HOST宛IPv6) の肯定応答あり + HTTPS肯定あるいは否定応答なし = 条件A成立せず
4. Resolution Delay開始
5. Resolution Delayタイムアウト
6. 何らかの肯定的アドレス応答を受信 + Resolution Delay超過 = 条件B成立
7. IPv6接続開始
8. 7から250ms後にIPv4接続開始
    - HTTPS応答次第優先度順でアドレスを並び替える必要がある

#### (shioimm)
- SvcPriority = 0の場合はAliasModeなので同じTargetNameに対してHTTPS再クエリが必要
- TargetName = altの場合はTargetNameに対してA/AAAA再クエリが必要

### TargetName = altの場合
#### AAAA先着
1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (アドレスヒントなし) -> altへA/AAAAクエリ / AAAA (HOST宛2件アドレス)
3. 優先アドレスファミリ (HOST宛IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
4. HOST宛IPv6接続開始
5. 2ms後にA応答
    - altのA応答 -> アドレスリストをIPv6 (HOST) + IPv4 (alt) へ更新
    - HOSTのA応答 -> アドレスリストをIPv6 (HOST) + IPv4 (HOST) へ更新
6. 250ms後に二つ目の接続開始
    - アドレスリストがIPv6 (HOST) + IPv4 (alt) -> alt宛IPv4接続
    - アドレスリストがIPv6 (HOST) + IPv4 (HOST) -> HOST宛IPv4接続

#### A先着/10ms後にAAAA応答
1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (アドレスヒントなし) -> altへA/AAAAクエリ / A応答 (2アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答なし + HTTPS肯定応答 = 条件A成立せず
4. Resolution Delay開始
5. 10ms後に応答
    - altのAAAA応答 -> 優先アドレスファミリ (alt宛IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
    - altのA応答 -> 優先アドレスファミリ (IPv6) の肯定応答なし + HTTPS肯定応答 = 条件A成立せずRD継続
    - HOSTのAAAA応答 -> 優先アドレスファミリ (HOST宛IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
6. アドレスリストを更新
    - altAAAA応答 -> アドレスリストをIPv6 (alt) + IPv4 (HOST) へ更新
    - HOSTのAAAA応答あり -> アドレスリストをIPv6 (HOST) + IPv4 (HOST) へ更新
7. IPv6接続開始
    - アドレスリストがIPv6 (alt) + IPv4 (HOST) -> alt宛IPv6接続
    - アドレスリストがIPv6 (HOST) + IPv4 (HOST) -> HOST宛IPv6接続
8. 250ms後にIPv4接続開始
    - 7-8の間にaltのA応答あり -> alt宛のIPv4接続を開始する
    - 7-8の間にaltのA応答なし -> HOST宛のIPv4接続を開始する

#### A先着/Resolution Delayタイムアウト
1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (アドレスヒントなし) -> altへA/AAAAクエリ / A応答 (2アドレス)
3. 優先アドレスファミリ (IPv6) の肯定応答なし + HTTPS肯定応答 = 条件A成立せず
4. Resolution Delay開始
5. Resolution Delayタイムアウト
6. 何らかの肯定的アドレス応答を受信 + Resolution Delay超過 = 条件B成立
7. HOST宛IPv4接続開始
8. 7から100ms後に応答
    - altのAAAA応答 -> アドレスリストをIPv6 (alt) + IPv4 (HOST) へ更新
    - altのA応答 -> アドレスリストをIPv4 (alt) + IPv4 (HOST) へ更新
    - HOSTのAAAA応答 -> アドレスリストをIPv6 (HOST) + IPv4 (HOST) へ更新
9. 7から250ms後に接続開始
    - アドレスリストがIPv6 (alt) + IPv4 (HOST) -> alt宛IPv6接続
    - アドレスリストがIPv4 (alt) + IPv4 (HOST) -> alt宛IPv4接続
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
2. HTTPS応答 (TargetName = HOST / アドレスヒントあり)
3. 優先アドレスファミリ (HOST宛IPv6アドレスヒント) の肯定応答 + HTTPS肯定応答 = 条件A成立
4. IPv6アドレスヒント宛にIPv6接続開始
5. 4から250ms後、IPv4アドレスヒント宛にIPv4接続開始

### TargetName = altの場合
1. HTTPS / AAAA / A をDNS問い合わせ
2. HTTPS応答 (TargetName = alt / ヒントあり)  -> altへA/AAAAクエリ
3. 優先アドレスファミリ (alt宛IPv6アドレスヒント) の肯定応答 + HTTPS肯定応答 = 条件A成立
4. IPv6アドレスヒント宛にIPv6接続開始
5. 4から250ms後
    - altへのA応答があった場合
      - -> アドレスリストをIPv6 (altアドレスヒント) + IPv4 (alt) へ更新
      - -> alt宛IPv4接続開始
    - altへのAAAA応答があった場合
      - -> アドレスリストをIPv6 (alt) + IPv4 (altアドレスヒント) へ更新
      - -> altアドレスヒント宛IPv4接続開始
    - HOSTへのA応答があった場合
      - -> アドレスリストをIPv6 (altアドレスヒント) + IPv4 (altアドレスヒント) + IPv4 (HOST) へ更新
      - -> altアドレスヒント宛 / HOST宛どちらか優先度の高い方へIPv4接続開始
    - HOSTへのAAAA応答があった場合
      - -> アドレスリストをIPv6 (altアドレスヒント) + IPv4 (altアドレスヒント) + IPv6 (HOST) へ更新
      - -> altアドレスヒント宛IPv4接続開始
    - 応答がなかった場合 -> altアドレスヒント宛IPv4接続開始

#### IPv6アドレスヒント宛に接続開始後にaltのA/AAAAが届き、かつアドレスヒントの値と異なる場合

1. HTTPS / AAAA / A をDNS問い合わせ
2. 30ms後にHTTPS応答 (TargetName = HOST / ヒントなし・TargetName = alt / ヒントあり) -> altへAAAA/Aクエリ
3. 優先アドレスファミリ (alt宛IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
4. アドレスリストをIPv6 (altアドレスヒント) + IPv4 (altアドレスヒント) へ更新
5. altアドレスヒント宛IPv6接続開始
6. 5から30ms後にalt宛AAAA応答 (1アドレス) / A応答 (1アドレス)
7. アドレスリストをIPv6 (alt) + IPv4 (alt) へ更新
8. 5から250ms後にalt宛IPv4へ接続開始 (IPv6に接続し直す必要なし)

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
    | Update w/IPv6 + IPv4       |
    |                            |
```

1. HTTPS / AAAA / A をDNS問い合わせ
2. 30ms後に応答
    - HTTPS (TargetName = HOST・TargetName = alt)  -> altへAAAA/Aクエリ
    - AAAA (HOST宛2アドレス)
    - A (HOST宛2アドレス)
3. 優先アドレスファミリ (HOST宛IPv6) の肯定応答 + HTTPS肯定応答 = 条件A成立
4. アドレスリストをIPv6 (HOST) + IPv4 (HOST) へ更新
5. HOST宛IPv6接続開始
6. 5から30ms後にalt宛AAAA応答 / A応答
7. アドレスリストをIPv6 (alt) + IPv4 (alt) + IPv6 (HOST) + IPv4 (HOST)
8. 5から250ms後にaltとHOSTいずれか優先度の高い方宛IPv4へ接続開始

## SVCB応答が遅延する場合 (IPv4接続のみ)

```text
# 推定されるHTTPS RRの例

example.com.  3600  IN  HTTPS  1  .  alpn="h3,h2"
```

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

1. HTTPS / A をDNS問い合わせ
2. 30ms後にA応答 (HOST宛2アドレス)
3. 優先アドレスファミリ (HOST宛IPv4) の肯定応答 + HTTPS応答なし = 条件A成立せず
4. アドレスリストをIPv4 (HOST) へ更新
5. Resolution Delay開始
6. 10ms後にHTTPS (アドレスヒントなし) 応答
7. HOST宛IPv4接続開始

## TODO 考える
- HSVCB応答が遅延する場合 (IPv4/IPv6接続のみ) で、HTTPS RRがIPv6アドレスヒントを持つ場合
- HSVCB応答が遅延する場合 (IPv4/IPv6接続のみ) で、HTTPS RRのTargetNameがaltの場合
- アドレスヒントがIPv6 / IPv4片方しかないパターン
