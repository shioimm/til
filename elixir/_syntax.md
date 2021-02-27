# 文法
- プログラミングElixir 第4章 / 第5章 / 第6章 / 第10章

## 変数名
- モジュール、レコード、プロトコル、ビヘイビアの名前はアッパーキャメルケース
- それ以外の識別子は小文字かアンダースコア`_`始まりの小文字

## 真偽値
- `true` / `false` / `nil`
  - 同名のアトムへのエイリアス

## 演算子
- 比較演算子
- ブール演算子(`and` / `or` / `not`)
  - ゆるいブール演算子(`||` / `&&`/ `!`)
- 算術演算子
- 連結演算子(`<>` / `++` / `--`)
- `in`演算子

## 変数のスコープ
- レキシカルスコープ

### `with`式
- `do`~`end`ブロックの中で使用する一時変数を定義する

```exs
# プログラミングElixir 4.8 basic-types/with-scopes.exs

lp = with { :ok, file } = File.open("/etc/passwd"),
          content       = IO.read(file, :all),
          :ok           = File.close(file),
          [_, uid, gid] = Regex.run(~r/^lp:.*(\d+):(\d+)/m, content)
     do
       "Group: #{gid}, User: #{uid}"
     end
```

## 無名関数
- `fn`~`end`キーワードで定義する

```exs
sum = fn(a, b) -> a + b end # #Function<13.126501267/2 in :erl_eval.expr/5>
sum.(1, 2)                  # => 3

swap = fn({ a, b }) -> { b, a } end # => #Function<7.126501267/1 in :erl_eval.expr/5>
swap.({ 1, 2 })                     # => {2, 1}
```

- 同じ関数の中で渡された引数の型と内容によって異なる実装を定義する

```exs
# プログラミングElixir 5.2 first-steps/handle_open.exs

handle_open = fn
  { :ok, file } -> "OK: #{IO.read(file, :line)}"
  { _, error } -> "Error: #{:file.format_error(error)}"
end

IO.puts handle_open.(File.open("../intro/hello.exs")) # => OK: IO.puts "Hello, World!"
IO.puts handle_open.(File.open("./noexistent"))       # => Error: no such file or directory
```

### クロージャ
- 関数は、関数が定義されたスコープにある変数の束縛を関数自身と一緒に持ち回る

```exs
greeter = fn
  name -> (fn -> "Hello, #{name}" end)
end

greeter.("World")
greet_world.() # => Hello, World
```

### 高階関数
- 関数を引数に渡す

```exs
times_2 = fn n -> n * 2 end

apply = fn(fun, value) -> fun.(value) end

apply.(times_2, 6) # => 12
```

```exs
Enum.map([1, 2, 3], fn elem -> elem * 2 end) # => [2, 4, 6]
```

### `&`演算子
- `&`以降の式を無名関数にする

```exs
# add_one = fn n -> n + 1 end
add_one = &(&1 + 1)

# square = fn x, y -> x * y end
square = &(&1 * &2)

# speak = fn x -> IO.puts x end
speak = &(IO.puts(&1))
```

```exs
divrem = &{ div(&1, &2), rem(&1, &2) }
divrem.(13, 5) # => {2, 3}

s = &"bacon and #{&1}"
s.("custard")  # => "bacon and custard"

match_end = &~r/.*#{&1}$/
"cat" =~ match_end.("t") # => true
"cat" =~ match_end.("!") # => false
```

- すでに存在する関数の名前とarityを渡すと、それを呼び出す無名関数を返す
```exs
len = &length/1
len.([1, 2, 3]) # => 3

len = &Enum.count/1
len.([1, 2, 3]) # => 3
```

## 名前付き関数
- `def` - パブリック関数定義
- `defp` - プライベート関数定義(モジュール内でのみ呼び出せる関数)
```exs
# プログラミングElixir 6 mm/times.exs

defmodule Times do
  def double(n) do
    n * 2
  end
end

# => double/1 (引数を一つ取る関数double)を定義
```

```exs
# `do...end`形式はキーワードリスト`do:`形式のシンタックスシュガー

defmodule Times do
  def double(n), do: n * 2
end
```

- 同じ関数名で渡された引数の型と内容によって異なる実装を定義する

```exs
# プログラミングElixir 6.3 mm/factorial1.exs

defmodule Factorial do
  def of(0), do: 1
  def of(n), do: n * of(n - 1)
end
```

### ガード節 / `when`キーワード
- 引数の型、値の評価のチェックによって異なる実装を定義する

```exs
# プログラミングElixir 6.4 mm/guard.exs

defmodule Guard do
  def what_is(x) when is_number(x) do
    IO.puts "#{x} is a number"
  end

  def what_is(x) when is_list(x) do
    IO.puts "#{inspect(x)} is a list"
  end

  def what_is(x) when is_atom(x) do
    IO.puts "#{x} is an atom"
  end
end
```

#### ガード節に渡せる式
- 比較演算子
- ブール演算子 / 否定演算子
- 連結演算子
- `in`演算子
- 型チェック関数
- その他

### デフォルトパラメータ
- `パラメータ\\値`構文によって引数にデフォルト値を設定する

```exs
# プログラミングElixir 6.5 mm/default_params.exs

defmodule Example do
  def func(p1, p2 \\ 2, p3 \\ 3, p4) do
    IO.inspect [p1, p2, p3, p4]
  end
end

# パラメータは左から右に向かってマッチされる
Example.func("a", "b")           # => ["a", 2, 3, "b"]
Example.func("a", "b", "c")      # => ["a", "b", 3, "c"]
Example.func("a", "b", "c", "d") # => ["a", "b", "c", "d"]
```

### パイプ演算子
- `|>` - 左の項の式の結果をとって右の関数の呼び出しの第一パラメータとして渡す
  - パイプラインの中ではパラメータは括弧で囲む必要がある
```exs
(1..10)
|> Enum.map(&(&1 * &1))
|> Enum.filter(&(&1 < 10)) # => [1, 4, 9]

# 以下の式と等価
list = Enum.map((1..10), &(&1 * &1))
Enum.filter(list, &(&1 < 10))
```

## モジュール
- ネームスペースの提供
- 名前付き関数、マクロ、構造、プロトコル、他のモジュールをカプセル化する

```exs
defmodule X do
  def x_func do
    Y.y_func
  end

  defmodule Y do
    def y_func do
    end
  end
end
```

### モジュールのネスト
- 全てのモジュールはトップレベルで定義される

```exs
defmodule X do
  def x_func do
    Y.y_func
  end
end

defmodule X.Y do
  def y_func do
  end
end
```

### モジュールのディレクティブ
#### `import`ディレクティブ
- モジュールの関数やマクロをカレントスコープに持ってくる
- `import モジュール名`
  - `import モジュール名, only: 関数名: arity`
  - `import モジュール名, except: 関数名: arity`
    - 関数名を`:function`にする -> 関数のみを取り込む
    - 関数名を`:macros`にする -> マクロのみを取り込む

```exs
# プログラミングElixir 6.9 mm/import.exs

defmodule Example do
  def func do
    # Listモジュールのflatten/1関数をimportする
    import List, only: [flatten: 1]
    flatten [5, [6, 7], 8]
  end
end
```

#### `alias`ディレクティブ
- モジュールのエイリアスを作る
- `alias モジュール名, as: エイリアス名`
  - `as:`パラメータはモジュール名の最後の部分をデフォルト値とする

```exs
defmodule Example do
  def func do
    alias X, as Y
    Y.y_func
  end
end
```

#### `require`ディレクティブ
- モジュールで定義したマクロを使うときはそのモジュールを`require`する

### モジュールの属性
- モジュールは対応するメタデータ(属性)を持つ
  - `@属性名 値` - 属性に値をセットする
    - 属性は関数の中でセットすることはできない

```exs
# プログラミングElixir 6.9 mm/attributes.exs

defmodule Example do
  @musician "Patti Smith"

  def get_musician do
    @musician
  end
end
```

### モジュールの名前
- Elixirのモジュールの名前は内部的には`Elixir`をprefixにつけたアトム
```exs
is_atom IO      # => true
Elixir.IO == IO # => true
```

- Erlangのモジュールの名前は単純なアトム
```exs
# ioモジュールのformat関数

:io.format("~3.1f~n", [1.23]) # => 1.2 / :ok
```

## 内包表記
- 与えられた一つ以上のコレクションに対して各要素の値のすべての組み合わせを展開する
  - 内包表記の内側で代入されたすべての変数は、その内包表記の中でだけ利用できる
    (内包表記の外側のスコープには影響を与えない)

```exs
for ジェネレータまたはフィルタ [, into: 値 ], do: 式
```

```exs
for x <- [1, 2, 3], do: x * x           # => [1, 4, 9]

for x <- [1, 2, 3], x == 2, do: x * x   # => [4]

for x <- [1, 2], y <- [3, 4], do: x * y # => [3, 4, 6, 8]
```

```exs
minmaxes = [{ 1, 4 }, { 2, 3 }, { 10, 12 }]
for { min, max } <- minmaxes, n <- min..max, do: n
# => [1, 2, 3, 4, 2, 3, 10, 11, 12]

n = [1, 2, 3, 4, 5, 6, 7]
for x <- n, y <- n, x >= y, rem(x * y, 10) == 0, do: { x, y }
# => [{5, 2}, {5, 4}, {6, 5}]
```

```exs
for << ch <- "hello" >>, do: << ch >>
# => ["h", "e", "l", "l", "o"]

for << << b1::size(2), b2::size(3), b3::size(3) >> <- "hello" >>, do: "0#{b1}#{b2}#{b3}"
# => ["0150", "0145", "0154", "0154", "0157"]
```

### `into`パラメータ
- `into`パラメータは内包表記の結果を受け取る

```exs
for x <- ~w{ cat dog }, into: %{}, do: { x, String.upcase(x) }
# => %{"cat" => "CAT", "dog" => "DOG"}

for x <- ~w{ cat dog }, into: IO.stream(:stdio, :line), do: "#{x}\n"
cat
dog
# => %IO.Stream{device: :standard_io, line_or_bytes: :line, raw: false}
```
