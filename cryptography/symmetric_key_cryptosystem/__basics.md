# 共通鍵暗号方式 (秘密鍵暗号 / 対称鍵暗号)
- 暗号鍵と復号鍵が同一である暗号化方式
- 暗号化と復号化の処理が高速
- 通信相手ごとに鍵が必要
- 安全な鍵の管理・配布(鍵配送問題)が困難

```
// 暗号化
c = Enc(m, s)

// 復号
m = Dec(s, c)
```

- c: ciphertext
- m: message
- s: secret
- Enc: encrypt
- Dec: decrypt

#### 共通鍵暗号方式に求められる安全性
- 強秘匿性 (暗号文から元の平文の情報を一部でも推測するのが困難)
- 選択平文攻撃 / 選択暗号文攻撃への強秘匿性

## 動作フロー
1. 送信者-受信者間で暗号化アルゴリズムを取り決める
2. 送信者-受信者間で共通鍵を取り決める
3. 送信者は共通鍵を使用してデータを暗号化し、送信する
4. 受信者は暗号化されたデータを受信し、共通鍵で復号化する

## 参照
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
- プロフェッショナルSSL/TLS
- マスタリングTCP/IP 入門編
- マスタリングTCP/IP 情報セキュリティ編
- 暗号技術入門 第3版
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書