# 公開鍵暗号方式
- 暗号鍵と復号鍵が異なる暗号化方式
  - Ex. RSA、ElGaml方式、Rabin方式、楕円曲線暗号
- 公開鍵によって暗号化し、秘密鍵によって復号する
- 秘密鍵から公開鍵を求めることはできるが、公開鍵から秘密鍵を求めることは困難
- 共通鍵暗号に比べて処理速度が格段に遅い
- 暗号の解析は困難である一方、中間者攻撃によるなりすましによって暗号文の改竄は可能

## 動作フロー
1. Alice、Bobはあらかじめ暗号化アルゴリズムを取り決める
2. Bobは公開鍵B、秘密鍵bのペアを作成する
3. AliceはBobの公開鍵Bを受け取る
4. AliceはBobの公開鍵Bで平文mを暗号化して暗号文cを作成しBobに送信する (c = Enc(B, m))
5. Bobは暗号文cを秘密鍵bを使って平文mに復号する (m = Dec(b, c))

#### ポイント
- 鍵の管理と配布が簡単
- 暗号化と復号化の処理に時間がかかる

## 参照
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
- プロフェッショナルSSL/TLS
- マスタリングTCP/IP 入門編
- 暗号技術入門 第3版
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書
