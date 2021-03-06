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
  - アプリケーション特有の動作を追加したい関数をアプリケーション側で上書きする

## GenServer
- サーバーのビヘイビア
  - ソースコードに`use GenServer`を記述することで使用できる

### コールバック関数
#### `init(start_arguments)`
- (サーバーが開始するとき)`GenServer.start_link`に対して呼ばれる

```exs
def init(クライアントから最初に受け取る引数) do
  { :ok, サーバーの初期状態 }
end
```

```exs
{:ok, pid} = GenServer.start_link(GenServerをuseするモジュール, initに渡す最初の引数)
```

#### `handle_call(request, from, state)`
- `GenServer.call`に対して呼ばれる
- 返り値を必要とするリクエストを処理する

```exs
def handle_call(:アクション, クライアントのPID, サーバーの状態) do
  # クライアントにレスポンスを送らず、状態を更新する
  #  => { :noreply, new_state [, :hibernate | :timeout] }
  # クライアントにレスポンスを送り、状態を更新する
  #  => { :reply, response, new_state [, :hibernate | :timeout] }
  # クライアントにレスポンスを送らず、サーバーに停止の合図をする
  #  => { :stop, reason, new_state }
  # クライアントにレスポンスを送り、サーバーに停止に合図をする
  #  => { :stop, reason, reply, new_state}
end

# 更新されたサーバーの状態 = 次の`handle_call`関数呼び出し時の「サーバーの状態」
```

```exs
GenServer.call(pid, :callするアクション)
```

#### `handle_cast(request, state)`
- `GenServer.cast`に対して呼ばれる
- 返り値を必要としないリクエストを処理する

```exs
def handle_cast({ :ハンドラ, サーバーの状態に追加する差分 }) do
  # クライアントにレスポンスを送らず、状態を更新する
  #  => { :noreply, new_state [, :hibernate | :timeout] }
  # クライアントにレスポンスを送らず、サーバーに停止の合図をする
  #  => { :stop, reason, new_state }
end
```

```exs
GenServer.cast(pid, { :ハンドラ, サーバーの状態に追加する差分 })
```

#### `handle_info(info, state)`
- `call`や`cast`以外でやってくるメッセージを処理するために呼ばれる

#### `terminate(reason, state)`
- サーバーが終了するときに呼ばれる

#### `code_change(from_version, state, extra)`
- 実行されているサーバーを、システムを止めずに置き換える

#### `format_status(reason, [pdict, state])`
- サーバー状態の表示方法のカスタマイズに使用される
  - デフォルトでは`[data: [{'State', state_info}]]`

### スーパーバイザ
- プロセスの死活監視を行うビヘイビア
