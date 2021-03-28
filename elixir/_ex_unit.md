# ExUnit
- Elixir実践ガイド 23

## TL;DR
- Elixir組み込みのテストフレームワーク

## 書き方
```exs
ExUnit.start()

defmodule XxxTest do
  use ExUnit.case

  describe "テストグループ" do
    test "テストケース1" do
      assert モジュール.関数() == 真となる条件
    end

    test "テストケース2" do
      assert_raise 例外, fn ->
        モジュール.関数()
      end
    end

    test "テストケース3"
  end
end
```

- `describe`はネストできない
- ブロックのない`test`はテストが未実装であることを示し、必ず失敗する
  - `ExUnit.start()` -> `ExUnit.start(exclude: :not_implemented)`でスキップする
  - mixで実行する場合は`$ mix test --exclude not_implemented`で実行する
