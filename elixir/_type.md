# 型
- プログラミングElixir 第4章

## 値型
- 整数
- 浮動小数点数
- アトム(`:xxx`)
  - 何かの名前を表現する定数
  - 同じ名前のアトム同士はどんな環境でも常に等価
- 範囲(`x..y`)
- 正規表現(`~r{regexp}` / `~r{regexp}opts`)

## システム型(Erlang VMのリソースを反映する)
- PID
  - プロセスへの参照
- ポート
  - 読み書きするリソースへの参照

## コレクション型
- タプル(`{ x, y }`)
  - 順序を持ったコレクション
  - 2 ~ 4要素を持つ(-> それ以上はマップまたは構造体を使用する)

```exs
# File.open("xxx.exs")がステータス(:ok / :error)とPIDを返す場合

{ :ok, file } = File.open("xxx.exs")

# 成功時: { :ok, #PID<x.y.z> }

# 失敗時: ** (MatchError) no match of right hand side value: {:error, :enoent}
```

- リスト(`[x, y]`)
  - 連結データ構造のリスト
  - リストは空か、一つのヘッドと一つのテイルから構成される(`[ ヘッド | テイル ]`)
    - Ex. `[1]`       = `[ 1 | [] ]`
    - Ex. `[1, 2]`    = `[ 1 | [ 2 | [] ] ]`
    - Ex. `[1, 2, 3]` = `[ 1 | [ 2 | [ 3 | [] ] ] ]`
  - リストを操作するために`List`モジュールが提供されている

```exs
# リストのパターンマッチ
[a, b, c] = [1, 2, 3] # a = 1 / b = 2 / c = 3
[ a | b ] = [1, 2, 3] # a = 1 / b = [2, 3]

# リストの操作
[1, 2] ++ [3] # => [1, 2, 3]
[1, 2] -- [2] # => [1]

1 in [1, 2] # => true
3 in [1, 2] # =>false
```

- キーワードリスト(`[{ :x, 1 }, { :y, 2 }]`)
  - `{ :キー, 値 }`をペアとした要素を持つリスト
  - `{ }`を省略して表現できる(`[x: 1, y: 2]`)
  - キーワードリストはキーが同じエントリを複数持つことができる
  - キーワードリストはコマンドラインパラメータやオプションの受け渡しの用途で使用される
  - リストを操作するために`Keyword` / `Enum`モジュールが提供されている

## マップ
- キーと値のペアのコレクション(`%{ :x => 1, :y => 2}`)
  - マップはキーが同じエントリを一つしか許容しない
  - マップは連想配列を利用する用途で使用される
  - マップを操作するために`Access` / `MapSet`モジュールが提供されている

```exs
%{ "one" => 1 }      # => %{"one" => 1}
%{ :two => 2 }       # => %{:two => 2}
%{ two: 2 }          # => %{:two => 2}
%{ {1, 1, 1 } => 3 } # => %{{1, 1, 1} => 3}

# マップへのアクセス
%{ "one" => 1 }["one"]             # => 1
%{ :two => 2 }[:two]               # => 2
%{ :two => 2 }.two                 # => 2
%{ { 1, 1, 1 } => 3 }[{ 1, 1, 1 }] # => 3
%{ { 1, 1, 1 } => 3 }[4]           # => nil

# マップの更新
# 古いマップをコピーして新しいマップを作る
m  = %{ a: 1, b: 2, c: 3 }         # => %{a: 1, b: 2, c: 3}
m1 = %{ m | b: "two", c: "three" } # => %{a: 1, b: "two", c: "three"}
m2 = %{ m1 | a: "one" }            # => %{a: "one", b: "two", c: "three"}
```

### 構造体
- マップのラッパーであるモジュール
- キーはアトム
- モジュール名が構造体の型名になる
- モジュールの中で`defstruct`マクロを使って構造体のメンバーを定義する

```exs
# プログラミングElixir 8.6 maps/defstruct.exs

defmodule Subscriber do
  defstruct name: "", paid: false, over_18: true
end
```

```exs
s1 = %Subscriber { name: "Mary", paid: true }
IO.puts s3.name # => "Mary"

%Subscriber { name: a } = s3
IO.puts a       # => "Mary"

s2 = Subscriber { s3 | name: "Marie" }
IO.puts s4.name # => "Marie"
```

#### 入れ子アクセサ

| アクセサ            | 用途                       | パラメータ(マクロ) | パラメータ(関数)    |
| -                   | -                          | -                  | -                   |
| `get_in`            | 値を取得する               | -                  | (dict, keys)        |
| `put_in`            | 値をセットする             | (path, value)      | (dict, keys, value) |
| `update_in`         | 値に関数を適用する         | (path, fn)         | (dict, keys, fn)    |
| `get_and_update_in` | 値を取得して関数を適用する | (path, fn)         | (dict, keys, fn)    |

## バイナリ型(`<<1, 2>>`)
- ビット列(0-255)

```exs
bin = <<1, 2>> # => <<1, 2>>
byte_size bin  # => 2

# 修飾子でフィールドごとの型と大きさを制御する
bin = <<1 :: size(8), 2 :: size(8)>> # => <<1, 2>>
byte_size bin                        # => 2
```

- `size(n)` - そのフィールドのビット数
- `signed` / `unsigned` - 符号付き / 符号なし(整数フィールド)
- `big` / `little` / native - エンディアン

```exs
<< length::unsigned-integer-size(12), flags::bitstring-size(4) >> = data
```

## Date型
- 年、月、日、暦を参照する(`~D[YYYY-MM-DD]`)

```exs
Date.new(1985, 1, 1)             # => {:ok, ~D[1985-01-01]}
Date.day_of_week(~D[1985-01-01]) # => 2
Date.add(~D[1985-01-01], 7)      # => ~D[1985-01-08]

Enum.count Date.range(~D[1985-01-01], ~D[1985-01-08]) # => 8

inspect ~D[1985-01-01], structs: false # => "%{__struct__: Date, calendar: Calendar.ISO, day: 1, month: 1, year: 1985}"
```

## Time型
- 時、分、秒、1秒以下の時刻を参照する(`~T[HH-mm-ss.ff...]`)

```exs
Time.new(12, 34, 56)             # => {:ok, ~T[12:34:56]}
Time.add(~T[12-34-56], 3600)     # => ~T[13:34:56.000000]
```
