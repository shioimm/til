# OTP
- プログラミングElixir 第17章

## TL;DR
- Erlangにルーツを持つライブラリ群・ツールキット
  - Erlang / Elixirコンパイラ
  - データベース
  - テストフレームワーク
  - プロファイラ
  - デバッグツール

## 定義
- OTPはシステムをアプリケーションの階層によって定義する
  - アプリケーションは一つ以上のプロセスによって構成される
  - プロセスはOTPのどれかの規約(ビヘイビア)に従う
  - ビヘイビアの実装は関連する一つのプロセス上で実行される
  - ビヘイビアにはデフォルトで動作に必要なコールバック関数が予め定義されている

### GenServer
- サーバーのビヘイビア
  - ソースコードに`use GenServer`を記述することで使用できる
- サーバーは初期化のための`init`関数を実装する

```exs
def init(クライアントから最初に受け取る引数) do
  { :ok, サーバーの初期状態 }
end
```

```exs
{:ok, pid} = GenServer.start_link(GenServerをuseするモジュール, initに渡す最初の引数)
```

- サーバーはクライアントから`call`関数を呼ばれると`handle_call`関数を実行する
  - `call` -> `handle_call` - 返り値を必要とするリクエストを処理する

```exs
def handle_call(:アクション, クライアントのPID, サーバーの状態) do
  { :アクション, リクエストへの返り値, 更新されたサーバーの状態 }
end

# 更新されたサーバーの状態 = 次の`handle_call`関数呼び出し時の「サーバーの状態」
```

```exs
GenServer.call(pid, :callするアクション)
```

- サーバーはクライアントから`cast`関数を呼ばれると`handle_cast`関数を実行する
  - 返り値を必要としないリクエストを処理する

```exs
def handle_cast({ :ハンドラ, サーバーの状態に追加する差分 }) do
  { :アクション, 更新されたサーバーの状態 }
end
```

```exs
GenServer.cast(pid, { :ハンドラ, サーバーの状態に追加する差分 })
```

- サーバーに`format_status`関数を実装すると、
  `:sys.get_status pid`実行時に得られる文字列を変更することができる

```exs
def format_status(_reason, [_pdict, state]) do
  [data: [{ 'State', "任意の情報" }]]
end
```

#### スーパーバイザ
- プロセスの死活監視を行うビヘイビア
