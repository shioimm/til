# データ型
#### 文字型
- character varying(n) / varchar(n) - 上限n文字までを格納可能な可変長データ型
- character(n) / char(n) - 上限n文字までを格納可能な固定長データ型 (n文字以下のデータは空白でパディング)
- text - 上限指定なしの可変長データ型 (最大1GB)

#### 数値データ型
- smallint - 2バイト・整数データ型
- integer - 4バイト・整数データ型
- bigint - 8バイト・整数データ型
- decimal - 可変長・正確な精度を保持する
- numeric - 可変長・正確な精度を保持する
- real - 4バイト・6桁の精度を持つ不正確なデータ型
- double precision - 8バイト・15桁の精度を持つ不正確なデータ型
- small serial - 2バイト・連番型
- serial - 4バイト・連番型
- bigserial - 8バイト・連番型

#### 日付・時刻データ型
- timestamp - 8バイト・日付と時刻を保持する・タイムゾーンなし
- timestamp with time zone - 8バイト・日付と時刻を保持する・タイムゾーンあり
- date - 4バイト・日付を保持する
- time - 8バイト・時刻を保持する・タイムゾーンなし
- time with time zone - 8バイト・時刻を保持する・タイムゾーンあり
- interval - 16バイト・時間間隔を保持する

#### バイナリ列データ型
- bytea - 最大1GB

## 参照
- 内部構造から学ぶpostgresql 設計 運用計画の鉄則 5.1
