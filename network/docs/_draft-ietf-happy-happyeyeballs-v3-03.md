# Happy Eyeballs Version 3: Better Connectivity Using Concurrency
https://datatracker.ietf.org/doc/draft-ietf-happy-happyeyeballs-v3/

## 1. Introduction
- 現代のインターネット上で動作する多くの通信プロトコルはホスト名を利用する
- これらのホスト名はしばしば複数のIPアドレスに名前解決され、それぞれが異なる性能特性や接続性の特性を持つ場合がある
- 特定のアドレスやアドレスファミリが、あるネットワーク上で遮断されていたり、故障していたり、
  最適ではない場合があるため、複数の接続を並行して試行するクライアントは、より迅速に接続を確立できる可能性がある
- 本書は、ユーザーに見える遅延を減らすためのアルゴリズムに対する要件を規定し、その一例となるアルゴリズムを提示する
- 本書で、デュアルスタックホストにおいてユーザーに見える遅延を減らす技術であるHappy Eyeballsのアルゴリズムを定義する
- Happy Eyeballsアルゴリズムは、名前解決されたアドレス群に対して接続試行を競争的に行う方式であり、
  可能な限りユーザーへの遅延を回避しつつ、IPv6の優先利用や、HTTP/3、TLS Encrypted Client Hello (ECH) のような
  プロトコルの利用可能性といったクライアント側の優先順位を尊重するため、いくつかの段階で構成されている
  - 本書では接続開始時にDNS問い合わせをどのように開始するか、
    DNS応答で得られた宛先アドレス一覧をどのように並べ替えるか、接続試行をどのように競争させるかについて論じる
- HEV2との主な違いは、SVCB / HTTPS Resource Records への対応が追加された点である
  - SVCBレコードは代替エンドポイント、アプリケーションプロトコル対応状況、Encrypted Client Hello (ECH) 鍵、
    アドレスヒント、アクセス対象サービスに関するその他の関連情報を提供する
- 名前解決中に (たとえばQUIC上のHTTP/3などの) プロトコルの対応状況を検出することにより、
  HTTP Alternative Services (Alt-Svc) など別の発見メカニズムから得た情報を利用して次回以降の接続試行を行うのではなく
  現在進行中の接続試行の段階でプロトコルをアップグレードできる
- これらのレコードはA / AAAAレコードとあわせて照会することができ、
  更新後のアルゴリズムでは接続確立を改善するためにSVCB応答をどのように扱うかを定義する

## 2. Conventions and Definitions
- MUST / REQUIRED / SHALL しなければならない
- MUST NOT / SHALL NOT してはならない
- SHOULD / RECOMMENDED する必要がある
- SHOULD NOT / NOT RECOMMENDED しないほうがよい
- MAY / OPTIONAL してもよい

## 3. Overview
- 本書は、Happy Eyeballs Connection Setupと呼ばれる接続確立方式を定義する

1. ホスト名を宛先アドレスへ非同期に名前解決する
2. 名前解決された宛先アドレスを並べ替える
3. 非同期の接続試行を開始する
4. 1つの接続を正常に確立し、その他の試行を取り消す

- 本書では、ホスト宛先アドレスに対する優先ポリシーがIPv4よりもIPv6を優先することを前提とする
- 本書では、優先ポリシーがTCPよりもQUIC を優先することも前提とする
- ホストが異なる優先設定となっている場合でも、本書の推奨事項は容易に適応できる

## 4. Hostname Resolution
- クライアントが名前付きホストへの接続を確立しようとする際、
  そのホストへ到達するために利用可能な宛先IPアドレスを判断する必要がある
- クライアントはDNS問い合わせを送信し、その応答を収集することで、ホスト名をIPアドレスへ名前解決する
- 本節ではクライアントがどのようにDNS問い合わせを開始し、その応答を非同期に処理するかについて論じる

### 4.1. Sending DNS Queries
- クライアントはまず、名前付きホストに対する問い合わせに、どのDNSリソースレコードを含めるかを判断する必要がある
  - この判断は、クライアントがIPv4およびIPv6の接続性を有しているかどうかに基づく
    - 接続性を有しているかどうか: そのアドレスファミリに属するローカルアドレスを少なくとも1つ持ち、
      かつ、そのアドレスファミリに対するリンクローカルではない経路を少なくとも1つ持つこと
- クライアントがIPv4とIPv6の両方の接続性を持つ場合、AAAAレコード / Aレコード両方の問い合わせを送信する必要がある
  - IPv4接続性のみを持つネットワークでは、Aレコードへの問い合わせを送信する
  - IPv6接続性のみを持つネットワークでは、ネットワーク構成に応じてAAAAレコード / Aレコード両方を問い合わせるか、
    AAAAレコードのみに問い合わせる
  - IPv6-mostlyおよびIPv6-only ネットワークの扱いについてはSupporting IPv6-Mostly and IPv6-Only Networksを参照
- AAAAレコード / Aレコードの要求に加え、どのアプリケーションが接続を確立しようとしているかに応じて、
  クライアントはSVCBレコードまたはHTTPSレコード(SVCB / HTTPS Resource Records) を要求できる
  - [SHOULD] HTTPまたはHTTPSを利用するアプリケーションの場合、クライアントはHTTPSレコードを問い合わせるべき
- [SHOULD] すべてのDNS問い合わせは、可能な限り互いに近いタイミングで行うべき
- [SHOULD] 問い合わせの送信順序は、上記の条件により不要なものを省いたうえで、以下の順序とするべき:
  - 1. SVCBまたはHTTPSへの問い合わせ
  - 2. AAAAへの問い合わせ
  - 3. Aへの問い合わせ

### 4.2. Handling DNS Answers Asynchronously
- クライアントは、DNS問い合わせに対して十分な応答を受信した時点で、
  アドレスの並べ替えおよび接続確立の段階へ進むことができる
- [SHOULD NOT] 実装はすべての応答を待ってから次の接続確立手順を開始するべきではない
  - ある問い合わせが失敗したり著しく遅れて返ってきたりする場合、
    すでに受信済みの応答だけで進行可能であった接続確立が、大きく遅延する可能性があるため
  - [SHOULD] クライアントはDNS名前解決を非同期処理として扱い、異なるレコード種別を独立して処理するべき
    - プラットフォームが非同期DNS APIを提供していない場合でも、
      各レコード種別について個別の同期問い合わせを並列実行することで、この動作を模擬できる
- クライアントは、以下のいずれかの条件群を満たした時点で、アドレスの並べ替えおよび接続確立へ進む

```
条件1
何らかの肯定的 (空でない) アドレス応答を受信している
&& 問い合わせ対象であった優先アドレスファミリについて肯定的 (空でない) または否定的 (空の) 応答を受信している
&& SVCB / HTTPS のサービス情報を受信している (または否定的応答を受信している)
```

```
条件2
何らかの肯定的 (空でない) アドレス応答を受信している
&& 他の応答が届かないまま、名前解決待機時間が経過している
```

- 肯定的応答: AAAA / Aレコードから得られたアドレス、またはSVCB / HTTPSレコードに含まれるaddress hintsによるアドレス
- 否定的応答: AAAA / A レコードに対する応答で、アドレスを含まないもの
  - NXDOMAIN (DNSサーバが検索されたドメイン名が存在しない) のようなエラーを伴う場合も、伴わない場合も含む
  - すべての応答が否定的応答であった場合、接続確立は失敗するか、別の応答が届くまで待機する必要がある
- IPv6およびIPv4の両方にデフォルトルートが存在するネットワークでは、IPv6が優先アドレスファミリであるとみなされる
- IPv6またはIPv4のどちらか一方にのみデフォルトルートが存在するネットワークでは、
  そのアドレスファミリを、アルゴリズム進行上の優先アドレスファミリとみなす
- Resolution Delayは、優先アドレス (AAAAレコード経由) およびサービス情報 (SVCB / HTTPS レコード経由) を
  受信する機会を与えるための短い待機時間
  - Resolution Delayは、AAAAレコードまたはSVCB / HTTPSレコードが、Aレコードより遅れて到着する場合を考慮したもの
  - Resolution Delay の推奨値は50ミリ秒

#### 4.2.1. Resolving SVCB/HTTPS Aliases and Targets
- SVCB / HTTPSレコードは、ネットワークサービスに関する情報を記述する
  - 個々のレコードはAliasModeまたはServiceModeのいずれか
    - AliasModeの場合、別名先の名前に対してさらにSVCB / HTTPS問い合わせを行う必要がある
    - ServiceModeの場合、元の問い合わせ名に対応する場合があり、その場合のTargetNameは `"."`
      - 別のサービス名に対応する場合もある ([SVCB / HTTPS Resource Records])
  - HEv3では、ServiceModeレコードが利用可能になるまで、サービス情報を受信したとはみなさない
  - ServiceModeレコードは`ipv6hint`および`ipv4hint`パラメータによってアドレスヒントを含むことがある
    - [SHOULD] これらを受信した場合、対応するTargetNameのA / AAAAレコードがまだ利用可能でないときは、
      アルゴリズム上、肯定的かつ空でない応答として扱うべき (shioimm: 利用可能でない = 応答を受信していない)
      - クライアントはそれらのTargetNameに対するA / AAAA問い合わせの応答を受信していない限り、
        引き続きA / AAAA問い合わせを送信する必要がある
        - 実際のA / AAAA問い合わせの応答を受信した時点でヒントは実際のレコードに置き換えられ、
          新たな応答として利用可能な応答集合が更新される

#### 4.2.2. Examples
TODO: 各種シナリオの例を示すこと

- 単純なデュアルスタック環境
- SVCB利用時
- AAAA応答が遅延する場合
- SVCB応答が遅延する場合
- SVCBヒントによって早期に応答が得られる場合

### 4.3. Handling New Answers
- 接続試行が進行中であり、まだいずれの接続も確立していない間に新しいレコードが到着した場合、
  新たに受信したアドレスは、利用可能な候補アドレス一覧に組み込まれる
  - 1つの接続が確立されるまで、新しいアドレスを追加した状態で接続試行処理を継続する

### 4.4. Handling Multiple DNS Server Addresses
- 現在のネットワークに複数のDNSサーバアドレスが設定されている場合、
  クライアントはDNS問い合わせをIPv4 / IPv6のいずれかで送信できる場合がある
- [SHOULD] Happy Eyeballsの考え方に従い、問い合わせはまずIPv6上で送信するべき
  - これはAAAA問い合わせやA問い合わせの種類ではなく、
    DNSサーバ自身のアドレスおよびDNSメッセージ輸送に用いるIPバージョンを指す
- IPv6アドレス宛てに送信したDNS問い合わせに応答が返らない場合、そのアドレスにはペナルティを与えたものとして扱い、
  他のDNSサーバアドレスへ問い合わせを送信してもよい
- ネイティブIPv6展開がより一般的になり、IPv4アドレスが枯渇していくにつれて、
  ネットワーク内ではIPv6接続性が優先的に扱われることが想定される
- DNSサーバがIPv6経由で到達可能なよう設定されている場合、IPv6を優先アドレスファミリとみなすべき
- [SHOULD NOT] クライアントシステムは、手動設定であってもネットワークから配布された設定であっても、
  設定可能なDNSサーバ数に明示的な上限を設けるべきではない
  - [SHOULD] ハードウェア上の制約によりそのような上限が必要な場合でも、
    クライアントは利用可能な一覧の中から、各アドレスファミリごとに少なくとも1つのアドレスを使用するべき

## 5. Grouping and Sorting Addresses
### 5.1. Grouping By Application Protocols and Security Requirements
#### 5.1.1. When to Apply Application Preferences
### 5.2. Grouping By Service Priority
### 5.3. Sorting Destination Addresses Within Groups
## 6. Connection Attempts
### 6.1. Determining successful connection establishment
### 6.2. Handling Application Layer Protocol Negotiation (ALPN)
### 6.3. Dropping or Pending Connection Attempts
## 7. DNS Answer Changes During Happy Eyeballs Connection Setup
## 8. Supporting IPv6-Mostly and IPv6-Only Networks
### 8.1. IPv4 Address Literals
### 8.2. Discovering and Utilizing PREF64
### 8.3. Supporting DNS64
### 8.4. Hostnames with Broken AAAA Records
### 8.5. Virtual Private Networks
## 9. Summary of Configurable Values
## 10. Limitations
### 10.1. Path Maximum Transmission Unit Discovery
### 10.2. Application Layer
### 10.3. Hiding Operational Issues
## 11. Security Considerations
## 12. IANA Considerations

## 13. References
### 13.1. Normative References
- [ECH] "TLS Encrypted Client Hello"
- [RFC2119] "Key words for use in RFCs to Indicate Requirement Levels"
- [RFC4821] "Packetization Layer Path MTU Discovery"
- [RFC6052] "IPv6 Addressing of IPv4/IPv6 Translators"
- [RFC6146] "Stateful NAT64: Network Address and Protocol Translation from IPv6 Clients to IPv4 Servers"
- [RFC6147] "DNS64: DNS Extensions for Network Address Translation from IPv6 Clients to IPv4 Servers"
- [RFC6298] "Computing TCP's Retransmission Timer",
- [RFC6535] "Dual-Stack Hosts Using "Bump-in-the-Host" (BIH)"
- [RFC6724] "Default Address Selection for Internet Protocol Version 6 (IPv6)"
- [RFC6724-UPDATE] "Prioritizing known-local IPv6 ULAs through address selection policy"
- [RFC7050] "Discovery of the IPv6 Prefix Used for IPv6 Address Synthesis",
- [RFC8174] "Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words"
- [RFC8781] "Discovering PREF64 in Router Advertisements"
- [RFC9000] "QUIC: A UDP-Based Multiplexed and Secure Transport"
- [RFC9460] "Service Binding and Parameter Specification via the DNS (SVCB and HTTPS Resource Records)"
- [SVCB] "Service Binding and Parameter Specification via the DNS (SVCB and HTTPS Resource Records)"
- [SVCB-ECH] "Bootstrapping TLS Encrypted ClientHello with DNS Service Bindings"

### 13.2. Informative References
- [AltSvc] "HTTP Alternative Services"
- [DNSSEC] "DNS Security Extensions (DNSSEC)", BCP 237,
- [DOH] "DNS Queries over HTTPS (DoH)"
- [DOQ] "DNS over Dedicated QUIC Connections"
- [DOT] "Specification for DNS over Transport Layer Security (TLS)"
- [HEV2] "Happy Eyeballs Version 2: Better Connectivity Using Concurrency"
- [HTTP3] "HTTP/3"
- [I-D.ietf-tls-key-share-prediction] "TLS Key Share Prediction"
- [IPV6] "Internet Protocol, Version 6 (IPv6) Specification"
- [QUIC] "QUIC: A UDP-Based Multiplexed and Secure Transport"
- [RFC6555] "Happy Eyeballs: Success with Dual-Stack Hosts"
- [RFC6877] "464XLAT: Combination of Stateful and Stateless Translation"
- [RFC7413] "TCP Fast Open"
- [RFC8446] "The Transport Layer Security (TLS) Protocol Version 1.3"
- [RFC8765] "DNS Push Notifications",
- [RFC9001] "Using TLS to Secure QUIC"
- [RFC9002] "QUIC Loss Detection and Congestion Control"
- [V6-MOSTLY] "IPv6-Mostly Networks: Deployment and Operations Considerations"
