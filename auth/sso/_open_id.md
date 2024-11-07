# OpenID
- インターネット上のサービスにおける認証をURL形式の一つのIDで実現する仕組み
- OpenID Foundationによって推進される

## 構成概念
#### OP (OpenID Provider)
- OpenIDで利用する識別子を発行し、利用者の認証を行う主体
- 利用者のアカウントの管理、Claimed Identifierの発行も行う
- RPからの認証要求に対して利用者の認証情報を渡す
- 拡張仕様の利用によって属性情報の提供を行うことができる

#### RP (Relyiny Party)
- OPへ認証要求を送信し、OpenIDの識別子を使った認証結果をOPから受け取ってサービスを提供する主体
- 拡張仕様の利用によってOPに利用者の属性情報を要求・取得することができる

#### User-Supplied Identifier
- 利用者が認証時に利用する識別子
  - Claimed Identifier
    - 利用者を示すためにOPが発行する識別子
    - URLもしくはXRI形式で表現される
  - OP Identifier
    - OP自身を示す識別子

#### OpenID AX(Attribute eXchange)(拡張仕様)
- OPとRPの間で属性情報のやりとりを可能にする拡張仕様

## 動作フロー
1. 利用者はRPにアクセスし、User-Supplied IdentifierとしてClaimed IdentifierまたはOP Identifierを入力する
2. RPは入力されたUser-Supplied IdentifierからOPを決定し、OPにアクセスする
3. RPはDH鍵共有アルゴリズムを用いてOPと暗号鍵を共有する
    - 暗号鍵は認証応答への署名に使用する
4. RPは利用者をOPにHTTPリダイレクトし認証を要求する
5. OPが利用者を認証する
6. OPは認証結果と利用者の情報をRPへリダイレクトする
7. 認証が成功した場合RPは利用者にサービスを提供する

## 参照
- Real World HTTP 第2版
- マスタリングTCP/IP 情報セキュリティ編
