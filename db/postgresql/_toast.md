# TOAST
- 大きなカラムの値を格納するための実装技法
- データ本体をTOAST領域に配置し、カラムにTOAST領域のデータへの参照を持つ
- 行のサイズが2kBより小さくなるように各カラムの値を圧縮し、行内とは別の領域に値を移動する

#### TOAST化戦略
- PLAIN
  - カラムに値を格納できない場合、圧縮・行外格納を行わずエラーを送出する
  - INTEGER、FLOAT、DOUBLE PRECISION、DATE、TIMESTAMP
- EXTENDED
  - カラムに値を格納できない場合、値を圧縮しTOAST領域に格納する
  - CHAR(n)、VARCHAR(n)、TEXT、BYTEA、JSON/JSONB
- EXTERNAL
  - カラムに値を格納できない場合、値を圧縮せずTOAST領域に格納する
- MAIN
  - カラムに値を格納できない場合、圧縮を行う。圧縮してもカラムに値を格納できない場合、TOAST領域に格納する
  - NUMERIC
