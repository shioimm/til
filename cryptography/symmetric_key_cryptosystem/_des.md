# DES
- Data Encryption Standard
- ブロック暗号化方式
- ブロック長64ビット単位で暗号化する
- 有効鍵長56ビット
  - 実際の鍵長64ビットのうち8ビットごとにパリティビットが含まれる
- 鍵の組み合わせ総数は`2 ** 56`パターン
  - 鍵長が短いため総当りで短時間に解析可能
- ラウンドを16回繰り返すファイステル構造による暗号方式

### ファイステル構造
- ラウンドを何度も繰り返す暗号方式
  - ラウンド - 暗号化の1ステップ
  - サブ鍵 - ラウンドごとに使われる部分的な鍵

```
1ラウンドあたりの処理:

1. ラウンドへの入力を左と右に分ける
2. 右をそのまま右へ送る
3. 左をラウンド関数へ送る
4. ラウンド関数は右とサブ鍵を使ってランダムに見えるビット列を計算する
5. 得られたビット列と左とのXORを計算した結果を暗号化された左とする
```

- 異なるサブ鍵を用いて何ラウンドも処理を繰り返し、ラウンドの合間で右と左を交換する
- ファイステル構造1ラウンド分の出力を同じサブ鍵のファイステル構造に入れることで復号可能

## 3DES
- triple-DES
- ブロック暗号化方式
- DESによる暗号化 -> 復号 -> 暗号化のシーケンスを行うことで暗号強度を高めた暗号化方式
  - 鍵を1種類使う場合(すべての鍵に同じビット列を使用した場合)単独のDESと等価
  - 鍵を2種類使う場合(DES-EDE2) - 有効鍵長は`56 * 2 = 112`ビット
  - 鍵を3種類使う場合(DES-EDE3) - 有効鍵長は`56 * 3 = 168`ビット
- 暗号化時と逆の順番で鍵を使って暗号化 -> 復号 -> 暗号化を行うことで復号可能

## 参照
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
- プロフェッショナルSSL/TLS
- マスタリングTCP/IP 入門編
- マスタリングTCP/IP 情報セキュリティ編
- 暗号技術入門 第3版
