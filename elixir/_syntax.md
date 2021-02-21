# 文法
- プログラミングElixir 第4章

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
# プログラミングElixir 4.8 変数のスコープ basic-types/with-scopes.exs

lp = with { :ok, file } = File.open("/etc/passwd"),
          content       = IO.read(file, :all),
          :ok           = File.close(file),
          [_, uid, gid] = Regex.run(~r/^lp:.*(\d+):(\d+)/m, content)
     do
       "Group: #{gid}, User: #{uid}"
     end
```
