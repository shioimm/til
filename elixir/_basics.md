# Elixir
- [elixir](https://elixir-lang.jp/)
- [getting-started](https://elixir-lang.jp/getting-started/introduction.html)
- [リファレンス](https://hexdocs.pm/elixir)
- プログラミングElixir 第1章 / 第14章

## IEx
- `$ iex`

### オプション
- `-S mix` - IExに`mix.exs`を適用する
  - Ubuntu20.4では別途`erlang-dev`のインストールが必要

### IExヘルパー
- `h 検索したいモジュールや関数` - ヘルプガイド
- `i 検索したい値` - 値についての情報を表示する
- `c "ファイル名"` - ソースファイルをコンパイルしてIExへロードする
  - あるいはコマンドラインで`$ iex ファイル名`を実行

### IExデバッグ
- ソースコード中で`require IEx; IEx.pry`を呼ぶことで
  ブレークポイントを仕込むことができる
  - `pry`モード中に`binding`を呼ぶとその時点でのローカル変数を出力できる
- IEx中に`require IEx; break! 対象の関数`を呼ぶことで
  任意のパブリックな関数にブレークポイントを仕込むことができる

### サーバーモニタリングツール
- `:observer.start()`
  - 基本的なシステム情報の表示
  - 動的な負荷のグラフ
  - ErlangETSテーブルの情報と内容
  - 実行中のプロセス
  - 実行中のアプリケーション
  - メモリ割り当て
  - 関数呼び出し、メッセージ、イベントトレース

## ソースファイル
- `.ex` - バイナリ形式にへコンパイルして実行するファイル
  - Ex. アプリケーションファイル
- `.exs` - コンパイルなしでスクリプトを実行するファイル
  - Ex. テストファイル

## ライブラリ
- Elixir標準ライブラリを使う
- Erlang標準ライブラリを使う
- [Hex](https://hex.pm/)を使う
- GitHubから探す
