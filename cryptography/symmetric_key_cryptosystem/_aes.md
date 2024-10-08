# AES
- Advanced Encryption Standard
- ブロック暗号化方式
- DESに変わる新しい標準暗号
- ブロック長128ビット単位で平文を暗号化する
- 鍵長128、192ビット、256ビットのいずれかが利用可能
- 比較的高速に処理が可能
- Rigndaelによる暗号方式

## Rigndael
- 秘密鍵に応じた初期設定の後、ラウンド関数処理を一定回数繰り返す暗号方式
  - 鍵長に応じて9回、11回、13回 (最終ラウンド関数を含めると10回、12回、14回)
- SPN構造を利用

#### 初期設定 (AddRoundKey)
1. ラウンド数に応じてラウンド鍵を作る
2. 128ビットから成る1ブロックを8ビットずつ16個のデータx0~x15に分割する
3. 2を4 * 4の正方形に並べる
4. ラウンド鍵と3の排他的論理和をとる

#### ラウンド関数
- SubBytes -> ShiftRows -> MixColumns -> AddRoundKeyを順に処理する
  - SubBytes
    - ブロックのテーブルのフィールド (各8ビットのデータx0~x15) に対して
      換字表 (S-Box) による換字式暗号を行う
  - ShiftRows
    - ブロックのテーブルの行ごとにデータを左にずらす
  -  MixColumns
    - ブロックのテーブルの列ごとに決められた行列Aをかける演算を行う

#### 最終ラウンド関数
- SubBytes -> ShiftRows -> AddRoundKeyを順に処理する

## AES-NI (AES New Instructions)
- Intel、AMDなどのCPUに搭載されたAESを高速処理するための専用命令
  - e.g. 秘密鍵からラウンド鍵を生成、暗号化・復号ラウンド関数、最終ラウンド関数

## 参照
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
- プロフェッショナルSSL/TLS
- マスタリングTCP/IP 入門編
- マスタリングTCP/IP 情報セキュリティ編
- 暗号技術入門 第3版
