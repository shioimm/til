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
### 4.2. Handling DNS Answers Asynchronously
#### 4.2.1. Resolving SVCB/HTTPS Aliases and Targets
#### 4.2.2. Examples
### 4.3. Handling New Answers
### 4.4. Handling Multiple DNS Server Addresses
