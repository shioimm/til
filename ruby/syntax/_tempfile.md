# Tempfileクラス
- 参照: [class Tempfile](https://docs.ruby-lang.org/ja/2.6.0/class/Tempfile.html)
- 参照: [Working with tempfiles](https://remimercier.com/working-with-tempfiles/)
- 一時ファイルを操作するクラス
- Fileオブジェクトと同じように操作できる
- スクリプト内で生成され、スクリプト終了時に削除される
  - Tempfile#openにより再オープンできる

### Fileオブジェクトとの違い
- ファイル名が必須ではない
- 生成後、スクリプト終了時に削除される
  - Tempfile#openにより再オープンできる
