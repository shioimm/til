# キュー (queue)
- 要素を追加した順に一列に並べ、最初に追加された要素の順に取り出すデータ構造
- 要素をFIFO方式で追加 (unshift) ・削除 (shift) する

#### 循環バッファ / リングバッファ
- 配列を使って実装されたキュー
- 要素を追加する位置を示すインデックス (tail) と要素を削除する位置 (head) を示すインデックスを持つ
- インデックスが配列の終端に達した場合は先頭に戻る
- tailがheadの直前である場合、キューが満杯の状態にある

## 参照
- [キュー 【queue】 待ち行列](https://e-words.jp/w/%E3%82%AD%E3%83%A5%E3%83%BC.html)
