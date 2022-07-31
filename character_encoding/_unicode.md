# Unicode
- (定義) Code Point (符号位置)
  - 文字に対する一意なID
- (実装) Code Unit (符号単位)
  - 1文字を表すのに使う最小限のビットの組み合わせ
- (実装) サロゲートペア
  - 2つのCode Unit (上位サロゲート + 下位サロゲート) の組み合わせで1つの文字（1つのCode Point）を表現する

### UTF-8
- Code Pointを1バイト (8ビット) 単位で符号化することができる (Code Unitのサイズが8ビット) 
  可変長マルチバイト文字コード
- UCS-2で定義される文字集合を用いて記述された文字列をバイト列に変換する方式の1つ
- 1文字を最小1~最大6バイトの可変長マルチバイトに変換する
  - 1バイト - ASCII
  - 2バイト - ヨーロッパ系文字集合
  - 3バイト - アジア系文字集合
  - 4バイト - その他

### UTF-16
- Code Pointを2バイト (16ビット) 単位で符号化することができる (Code Unitのサイズが16ビット) 
  可変長マルチバイト文字コード
- UCS-2で定義される文字集合を用いて記述された文字列にUCS-4の一部の文字を埋め込むためのエンコード方式
- UTF-8と併用することができる
- 2バイトで表現できる文字 (0x0000~0xD7FF、0xE000~0xFFFF) は2バイトで表し、
  それ以降 (0x00000000~0x0010FFFF) の文字は4バイトで表す

## 参照
- ［改訂新版］プログラマのための文字コード技術入門
- [【初心者向け】文字コードの種類と仕組み入門 ~ascii/Shift-JISの互換,UnicodeとUTF-8の違い,Base64/QPについて~](https://milestone-of-se.nesuke.com/nw-basic/as-nw-engineer/charset-summary/)
- [UTF-8とUTF16の違いは？](https://atmarkit.itmedia.co.jp/fxml/askxmlexpert/024utf/24utf.html)