# HEv3での代表的なシナリオ
### 接続試行に進むための条件 (OR)
- 条件A:
  - 何らかの肯定的アドレス応答を受信、
    かつ優先アドレスファミリ (通常IPv6) の肯定・否定応答を受信、
    かつSVCB / HTTPSのサービス情報の肯定・否定応答を受信
- 条件B:
  - 何らかの肯定的アドレス応答を受信、
    かつ他の応答が届かないままResolution Delay (推奨50ms) が経過

## 単純なデュアルスタック環境

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
7. (追記) 250ms後にIPv4接続開始

```text
# 推定されるHTTPS RRの例

example.com.  3600  IN  HTTPS  1  .  alpn="h3,h2"
```

#### (shioimm)
- TargetName != `.`の場合はTargetNameに対してA/AAAA再クエリが必要
- こんなにタイトに同じタイミングでHTTPS / AAAAが返ってくることはないのでは...

## SVCB利用時

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

## AAAA応答が遅延する場合

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

## SVCB応答が遅延する場合

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
