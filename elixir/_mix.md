# Mix
- プログラミングElixir 第13章 / 第14章

## TL;DR
- Elixirのプロジェクトを管理するためのコマンドラインユーティリティ
  - 新規プロジェクトの作成
  - 依存ライブラリの管理
  - テストの実行
  - コードの実行

```
$ mix help                      # ヘルプ
$ mix run -e '呼び出したい関数' # 関数をインラインで呼び出す
```

## Mixプロジェクト

```
$ mix new プロジェクト名
```

```
プロジェクト/
  ├── .formatter.exs # ソースコードのフォーマッタに使用される設定ファイル
  ├── .gitignore
  ├── README.md
  ├── config/
  │    └── プロジェクト.exs
  ├── deps/
  ├── lib/
  │    ├── プロジェクト/
  │    └── プロジェクト.ex
  ├── mix.exs # 設定ファイル
  └── test/
       ├── プロジェクト_test.exs
       └── test_helper.exs
```

### 規約
- CLI用のモジュールは`プロジェクト.CLI`と呼ばれ、エンドポイント`run`を持ち、
  コマンドライン引数の配列を一つ受け取る

### `test/`
- Mixで作成したプロジェクトは`test/プロジェクト名_test.exs`としてテストテンプレートを作成する
- `test/`以下に`モジュール名_test.exs`としてファイルを作成し
  テンプレートを元にしてテストを追加していく

```exs
# テンプレート

defmodule プロジェクト名Test do
  use ExUnit.Case
  doctest プロジェクト名

  test "greets the world" do
    assert プロジェクト名.hello() == :world
  end
end
```

- `setup` - テストのセットアップ
  - 各テストが実行される前に自動的に起動する(`setup_all`は一回だけ起動する)

```exs
setup do
  [
    キー: 値,
  ]
end

# fixtureとしてパラメータを渡すとfixture.キーでアクセスできる
test "テスト名", fixture do
  # ...
end
```

### `mix.exs`

```
defmodule プロジェクト名.MixProject do
  use Mix.Project

  def project do
    [
      app: :プロジェクト名,
      escript: escript_config(),
      version: "バージョン",
      elixir: "Elixirのバージョン",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # 依存ライブラリの記述
  # $ mix deps.getで依存ライブラリをインストール
  defp deps do
    [
      { :依存ライブラリ名, "バージョン" }
    ]
  end

  # escriptの設定
  # $ mix escript.buildでパッケージング
  defp escript_config do
    main_module: メイン関数を含むモジュール名
  end
end
```

#### 依存ライブラリ
- `mix.exs`の`deps`関数に必要な関数を追加する
- `$ mix deps` - ライブラリの状態を確認
- `$ mix deps.get` - 依存ライブラリのダウンロード
  - ライブラリはコンパイルされていない状態でダウンロードされる

### `config/config.exs`
- 設定情報を記述する

```exs
use Mix.Config

# 外部から環境を読み込む
import_config "#{Mix.env}.exs" # 環境に応じてdev.env / test.env / prod.envを呼び出す

# アプリケーション側で呼び出せる値を定義
config :名前空間, キー: 値
```

```exs
# アプリケーション側で値を呼び出せる

Application.get_env(:名前空間, :キー)
```

### コードの依存関係
- `$ mix xref unreachable` - 呼び出し時に不明な関数の一覧
- `$ mix xref warnings` - 依存関係に関する警告の一覧
- `$ mix xref callers MOD | MOD.func | MOD.func/arity` - モジュールや関数の呼び出し元一覧
- `$ mix xref graph` - アプリケーションの依存ツリーの表示

### コードフォーマット
- `$ mix format`
