# Linda
- 並列プログラミングにおける協調言語モデル
  - 異なる計算言語やOS間でも協調できる
- タプル (データ) とタプルスペース (分散共有メモリ) に対する操作によって並列化を行う
  - データタプル - プロセスタプルによって使用されるデータ
  - プロセスタプル - データタプルを生成、読み込み、消費する。実行終了後はデータタプルになる

## 操作 (C-Linda)
- `out(t)`
  - タプルtをタプルスペースに追加する
  - 命令を実行したプロセスはそのまま実行を継続する
- `in(s)`
  - パターンsにマッチしたタプルtをsに代入してタプルスペースから取り除く
    - 複数のtがマッチした場合はいずれかが選択される
  - 命令を実行したプロセスはそのまま実行を継続する
  - マッチするタプルがなければブロック
- `inp(s)`
  - inをノンブロックで行う
  - マッチするタプルがなければ0を返す
- `rd`
  - パターンsにマッチしたタプルtをsに代入する
  - マッチするタプルがなければブロック
- `rdp(s)`
  - rdをノンブロックで行う
  - マッチするタプルがなければ0を返す
- `eval(t)`
  - タプルtをタプルスペースに追加する (tはタプルスペースに入れられた後に評価される)
    - tの各フィールドの評価のために新たなプロセスを起動して評価する
    - 全てのフィールドが評価されたタプルは普通のデータタプルになる

## Rinda
- LindaのRuby実装
- [library rinda/rinda](https://docs.ruby-lang.org/ja/3.0.0/library/rinda=2frinda.html)
- タプルを複数の任意の値からなるArrayとして表現する

## 参照
- dRubyによる分散・Webプログラミング
