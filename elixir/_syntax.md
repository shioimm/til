# 文法
- プログラミングElixir 第4章 / 第5章

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

- 渡された引数の型と内容によって異なる実装を定義することができる

```exs
# プログラミングElixir 5.2 first-steps/handle_open.exs

handle_open = fn
  { :ok, file } -> "OK: #{IO.read(file, :line)}"
  { _, error } -> "Error: #{:file.format_error(error)}"
end

IO.puts handle_open.(File.open("../intro/hello.exs")) # => OK: IO.puts "Hello, World!"
IO.puts handle_open.(File.open("./noexistent"))       # => Error: no such file or directory
```

## クロージャ
- 関数は、関数が定義されたスコープにある変数の束縛を関数自身と一緒に持ち回る

```exs
greeter = fn
  name -> (fn -> "Hello, #{name}" end)
end

greeter.("World")
greet_world.() # => Hello, World
```

## 高階関数
- 関数を引数に渡す

```exs
times_2 = fn n -> n * 2 end

apply = fn(fun, value) -> fun.(value) end

apply.(times_2, 6) # => 12
```

```exs
Enum.map([1, 2, 3], fn elem -> elem * 2 end) # => [2, 4, 6]
```

## `&`演算子
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
