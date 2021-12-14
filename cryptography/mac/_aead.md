# 認証付き暗号 (AEAD: Authenticated Encryption with Associatiated Data)
- 暗号化と認証を同時に行い、秘匿性と完全性を両立する暗号方式
- TLS1.3ではAEADによる暗号化が必須

| -          | 秘匿性 | 完全性 |
| -          | -      | -      |
| 共通鍵暗号 | ○      | ×      |
| MAC        | ×      | ○      |
| AE         | ○      | ○      |

- Encrypt-then-MAC - 平文を共通鍵暗号で暗号化し、その後で暗号文のMAC値を計算する
- Encrypt-and-MAC - 平文を共通鍵暗号で暗号化し、それとは別に平文のMAC値を計算する
- MAC-then-Encrypt - 予め平文のMAC値を得て、平文とMAC値をまとめて暗号化する

## 動作フロー
1. Alice、Bobはあらかじめ秘密鍵sを決めて共有する
2. Aliceは平文m、秘密鍵s、nonce n、関連データdから暗号文cと認証タグtを作成
    - nonceは同じ値を一回のみ使用可能
    - 関連データは暗号化しないが改竄を防ぎたいヘッダ情報を想定
    - 関連データがない場合はAE: Authenticated Encryptionと呼ばれる
    - 認証タグはMACのMAC値に相当
2. Aliceはnonce n、関連データd、暗号文c、認証タグtの組み`(n, d, c, t)`をBobに送信
3. Bobは`(n, d, c, t)`と秘密鍵sを用いて完全性を検証する
4. Bobは正しい場合平文mを出力、誤っている場合何も出力しない

## TLS1.3で定義されたAEAD

| AEAD              | 暗号化方法     | 認証                | 鍵長          |
| -                 | -              | -                   | -             |
| AES-GCM           | AESのCTRモード | 有限体を使ったGHASH | 128/256ビット |
| AES-CCM           | AESのCTRモード | CBC-MAC             | 128ビット     |
| ChaCha20-Poly1305 | ChaCha20       | Poly1305            | 256ビット     |

#### 各パフォーマンス比較

| AEAD              | Intel系CPU | 組み込み系CPU |
| -                 | -          | -             |
| AES-GCM           | ◎          | ○             |
| AES-CCM           | △          | △             |
| ChaCha20-Poly1305 | ○          | ◎             |

## GCM
- 認証付き暗号の一種
- 128ビットブロック暗号をCTRモードで用いる
- MAC値を得るために加算と乗算を繰り返す一方向ハッシュ関数を用いる
- GMAC - GCMをメッセージ認証専用として用いたもの

## 参照
- 暗号技術入門 第3版
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書
