# AES
- Advanced Encryption Standard
- ブロック暗号化方式
- DESに変わる新しい標準暗号
- ブロック長128ビット単位で平文を暗号化する
- 鍵長128、192ビット、256ビットのいずれかが利用可能
- 比較的高速に処理が可能
- Rigndaelによる暗号方式

### Rigndael
- ラウンドを何度も繰り返す暗号方式
- SPN構造を利用

```
1ラウンドあたりの処理:

1. 16バイトの入力に対して1バイトごとにSubBytesを行う
     SubBytes - 1バイトの値をインデックスとし、256個の値を持つ変換表(S BOX)から1個の値を得る処理
2. 4バイト単位にまとまった行に対してShiftRowsを行う
     ShiftRows - 行を左に規則的にシフトする処理
3. 4バイト単位にまとまった列に対してMaxColumnsを行う
     MaxColumns - 列をビット演算を用いて別の4ビットの値に変換する処理
4. AddRoundKeyを行う
    AddRoundKey - MaxColumnsの出力とラウンド鍵とのXORをとる処理
```

## 参照
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
- プロフェッショナルSSL/TLS
- マスタリングTCP/IP 入門編
- マスタリングTCP/IP 情報セキュリティ編
- 暗号技術入門 第3版
