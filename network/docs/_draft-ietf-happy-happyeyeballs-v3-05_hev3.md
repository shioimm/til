# Happy Eyeballs Version 3: Better Connectivity Using Concurrency
https://datatracker.ietf.org/doc/draft-ietf-happy-happyeyeballs-v3/

## 1. Introduction
- 現代のインターネット上で動作する多くの通信プロトコルは、ホスト名を使用する
- ホスト名は多くの場合、複数のIPアドレスに名前解決され、それぞれが異なる性能や接続特性を持つ可能性がある
- 特定のアドレスやアドレスファミリ (IPv4またはIPv6) はネットワーク上で遮断されていたり、
  破損していたり、最適でなかったりする可能性がある
  - そのため、複数の接続を並行して試行するクライアントは、より迅速に接続を確立できる可能性がある
- 本書は、デュアルスタックホストでユーザが認識する遅延を低減する技術であるHappy Eyeballsのアルゴリズムを定義する
  - この定義は [HEV2] の記述を更新するものであり、[HEV2] 自体が [RFC6555] を置き換えたものである
- 名前解決されたエンドポイントに対して接続を競争させるHappy Eyeballsアルゴリズムは、
  ユーザへの遅延を可能な限り避けるために、いくつかの段階を持つ
  - その際IPv6の使用を優先することや、
    HTTP/3 [HTTP3] やTLS Encrypted Client Hello [ECH] といったプロトコルが利用可能であることなど、
    クライアントの優先事項を尊重する
- 本書では、接続を開始するときにDNS問い合わせをどのように開始するか、
  DNS応答で受け取った宛先アドレスのリストをどのように並べ替えるか、
  そして接続試行をどのように競争させるかについて論じる
- 本書で定義するアルゴリズムと [HEV2] の主な違いは、
  SVCB / HTTPSリソースレコード [SVCB] への対応が追加されたことである
  - SVCBレコードは、代替エンドポイント、アプリケーションプロトコルの対応状況、Encrypted Client Hello [ECH] の鍵、
    アドレスヒント、およびアクセス対象のサービスに関するその他の関連情報を提供する
  - HTTP/3 over QUIC [HTTP3] のようなプロトコルの対応状況を名前解決中に検出することで、
    HTTP Alternative Services [AltSvc] などの他の検出メカニズムの情報を使って後続の試行を行うのを待つのではなく、
    現在の接続試行の中でプロトコルをアップグレードできる
  - これらのレコードはAレコードやAAAAレコードと一緒に問い合わせることができ、
    更新されたアルゴリズムは接続確立を改善するためにSVCB応答をどう扱うかを定義する

## 2. Conventions and Definitions
変更なし

## 3. Overview
- 本書は、Happy Eyeballs Connection Setupと呼ぶ接続確立方式を定義する。この方式には、次のいくつかの段階がある
  - 1. ホスト名を宛先エンドポイントへ非同期に名前解決する (4. Hostname Resolution)
  - 2. 名前解決された宛先エンドポイントを並べ替える (5. Grouping and Sorting Addresses)
  - 3. 非同期の接続試行を開始する (6. Connection Attempts)
  - 4. 1つの接続を正常に確立し、その他の試行をキャンセルする (6. Connection Attempts)
- 本書は、宛先アドレスファミリの優先ポリシーがIPv4よりIPv6を優先することを前提とする
  - IPv6にはIPv4を改善するために設計された多くの望ましい特性がある [IPV6]
- 本書は、優先ポリシーがTCPよりQUICを優先することを前提とする
  - QUICは、セキュアな接続を確立するのに1パケットのみを必要とし、TCPと比べて高速 [QUIC]
-  ホストが異なる優先設定になっている場合でも本書の推奨事項は容易に適応できる

## 4. Hostname Resolution
- クライアントが名前のあるホストへ接続を確立しようとする際、
  接続を確立するために使用できる宛先エンドポイントを特定する必要がある
- クライアントはDNS問い合わせを送信して応答を収集することにより、エンドポイントを名前解決する
- 本節では、クライアントがDNS問い合わせをどのように開始し、その応答を非同期にどのように処理するかを説明する

### 4.1 Sending DNS Queries
### 4.2 Handling DNS Answers Asynchronously
#### 4.2.1. Resolving SVCB/HTTPS Aliases and Targets
#### 4.2.2. Examples
### 4.3. Handling New Answers
### 4.4. Handling Expired Answers
