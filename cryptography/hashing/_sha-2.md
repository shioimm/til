# SHA-2
- SHA-224、SHA-256、SHA-384、SHA-512、SHA-512/224、SHA-512/256の総称
  - SHA-以降の数値が出力するハッシュ値にビット数と一致する
- SHA-224とSHA-256、SHA-384とSHA-512の内部動作がほぼ同じ

## 動作フロー
1. 入力データを512ビットごとのブロックに分割する (B)
2. ブロックの余りに終了を示す1ビットの1を追加する
3. ブロックの余りにブロックの余りのサイズが448ビットになるように0を追加する
4. ブロックの余りに元の入力データのサイズを64ビット整数の形式で追加し、512ビットにする
5. 内部状態Sを用意する
    - SHA-224、SHA-256 - 8個の32ビット整数から成る256ビット整数
    - SHA-384、SHA-512 - 8個の64ビット整数から成る512ビット整数
6. 圧縮関数fを用意する
    - 圧縮関数は内部状態SとブロックBを入力とし、新しい内部状態S'を出力する
7. 内部状態Sを初期値IVで初期化し、各ブロックBiを入力する度に順次内部状態を更新する
8. 全てのブロックを入力して得られた最後の内部状態をハッシュ値hとして出力する

## 参照
- プロフェッショナルSSL/TLS
- マスタリングTCP/IP 情報セキュリティ編
- 暗号技術入門 第3版
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書