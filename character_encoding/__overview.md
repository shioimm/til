# 文字コード
- 文字 (character)
  - 図形文字 (e.g. 「あ」「い」「う」...)
  - 制御文字 (e.g. ビープ音、水平タブ、改行、エスケープ)
- 符号点 (code points)
  - 個々の文字に対して一意に割り当てる番号 (e.g. U+3042)
  - 16進数で表す
- 文字集合 (character set)
  - 文字の集まり
  - 文字ごとに群・面・区・点の番号が割り振られ、群は0～127、面・区・点は0～255の数値を取る
- 符号化文字集合 (coded character set)
  - 文字と符号点を1:1で対応付ける規則の集合
- 文字コード (character code)
  - 符号化文字集合
- シングルバイト文字コード (single byte character code)
  - 単一のバイトで1文字を表現する文字コード (ASCIIコード)
- マルチバイト文字コード (multi byte character code)
  - 複数バイトで1文字を表現する文字コード
  - 多くのマルチバイト文字コードはASCIIと互換性があり、先頭ビットが0の場合ASCIIと判断する
- 文字符号化方式（character encoding scheme)
  - 文字に対応づけられた符号点をバイナリコードに変換する方式
  - バイナリコードを文字符号化方式を用いて解釈するとことで文字に変換する
- エンコード
  - 文字集合を文字コードへ変換すること
- BOM (byte order mark)
  - Unicodeにおいてバイトオーダー (エンディアン) を示すために
    テキストの先頭にオプションとして付加する数バイトのデータ
- UCS (Unified Code Set) 正規化
  - 処理外部の文字列エンコーディングと別に、
    内部で扱う文字列エンコーディングを単一のもの (内部エンコーディング) に統一する方式
- CSI (Code Set Independent)
  - 処理内部に統一した内部エンコーディングを持たない方式

## 参照
- ［改訂新版］プログラマのための文字コード技術入門
- [【初心者向け】文字コードの種類と仕組み入門 ~ascii/Shift-JISの互換,UnicodeとUTF-8の違い,Base64/QPについて~](https://milestone-of-se.nesuke.com/nw-basic/as-nw-engineer/charset-summary/)
- [UTF-8とUTF16の違いは？](https://atmarkit.itmedia.co.jp/fxml/askxmlexpert/024utf/24utf.html)
