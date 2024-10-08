# 公開鍵証明書
- デジタル証明書を受け取った受信者はデジタル署名を認証局の公開鍵 (CA証明書) で復号し、
  署名前証明書のハッシュ値と比較検証する

#### 構成要素
- 署名前証明書 (サーバーやサーバーの所有者の情報)
- デジタル署名のアルゴリズム (デジタル署名で使用するハッシュ関数: 署名前証明書に含まれる)
- デジタル署名

## 分類
#### サーバー証明書
- サーバーを識別する証明書
- SSL/TLSサーバーが証明書のSubjectとなる
- Webサイトの所有者の情報、SSL/TLS通信における暗号化に必要な公開鍵などを含み、認証局によって署名される
- サーバー証明書とその秘密鍵は、サーバーの稼働するOS上で管理される

#### クライアント証明書
- サーバーを識別する証明書
- クライアントがSubjectとなる
- SSL/TLSのクライアント認証モードでSSL/TLSサーバーがクライアントを認証する際に使用する
- クライアント証明書とその秘密鍵は、Webブラウザなどにインストールされる場合が多い

#### ルート証明書
- 各種証明書を発行する認証局が、発行する証明書の署名の正当性を示すために自ら署名して発行する証明書

## 証明書チェーン
- 個々のサーバーが準備する、サーバー証明書と信頼の起点となるルート証明書とのセット
- クライアントはいずれもルート証明書に含まれる公開鍵で検証を行う

## 種類
- DV (Domain Validated certificate)
  - 被証明者がドメイン名を管轄していることの証明
- OV (Organizatioon Validation / 企業認証)
  - 被証明者がドメイン名を管轄していることの証明
  - 被証明者が法的に実在していることの証明
- EV (Extended Validation)
  - 被証明者がドメイン名を管轄していることの証明
  - 被証明者が法的に実在していることの証明
  - 被証明者が物理的に実在していることの証明

## 発行元
- 自己認証
- プライベート認証局 - 組織内で独自の運用基準を設けて設立・運営される認証局
- パブリック認証局 - 公的な認証局
  - ルート認証局
  - 中間認証局

## クライアント - サーバー間の認証
- クライアントは予め信頼できるルート認証局の証明書を複数インストールしている
- クライアントは予め自身にインストールされている証明書と
  サーバーから送信されたルート認証局の証明書が一致するかを確認する
  ‐ クライアントにはサーバー証明書とルート認証局の自己証明書が両方送信される
  - 一致した場合、受信した証明書は信頼できると判断する
- クライアントはルート認証局の証明書の中に入っている公開鍵でサーバー証明書に付けられた署名を検証する
  - 一致した場合、受信した証明書は信頼できると判断する

## 証明書発行手順
1. OpenSSLで秘密鍵を生成
2. 秘密鍵からCSR(証明書署名リクエスト)を作成
3. 認証局にCSRを提出しSSL証明書の発行を依頼
4. CAによる審査・証明書の発行
5. CAから発行される値でネームサーバー上にTXTレコードを作りDNS認証
6. SSL証明書・中間CA証明書が届く
    - SSL証明書(`.crt`)
    - 中間CA証明書(`.ca`)
    - SSL証明書 + 中間CA証明書
7. WebサーバーにSSL証明書・中間CA証明書を設置
    - 証明書を一ファイルにまとめる(`$ awk 1 xxx.crt yyy.ca > zzz.crt`)
8. Webサーバー上にHTTPSのバーチャルホストを作成
    - 秘密鍵・SSL証明書 + 中間CA証明書・暗号スイート・TLSプロトコルバージョンを指定

## 参照
- SSLをはじめよう ～「なんとなく」から「ちゃんとわかる！」へ～
- [図解で学ぶネットワークの基礎：SSL編](https://xtech.nikkei.com/it/article/COLUMN/20071002/283518/)
- ハイパフォーマンスブラウザネットワーキング
- サーバ／インフラエンジニアの基本がこれ1冊でしっかり身につく本 3.6
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
- プロフェッショナルSSL/TLS
- [OCSP (Online Certificate Status Protocol)](https://www.cybertrust.co.jp/sureserver/support/glossary/ocsp.html)
- マスタリングTCP/IP 情報セキュリティ編
- パケットキャプチャの教科書
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書
