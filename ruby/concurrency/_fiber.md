# class Fiber
- 軽量スレッド(coroutine / semicoroutine)
- ユーザレベルスレッドとして実装されている
  - ノンプリエンプティブな処理
- Threadとの違いとして、明示的にファイバーコンテキストの切り替えが必要
- 処理を途中まで実行し、あるポイントで他のルーチンにコンテキストを切り替え、
  その後任意のタイミングで最初の処理の途中から処理を再開するという目的のために使われる

### ファイバーの親子関係
- `Fiber#resume`を呼んだファイバーが親、呼ばれたファイバーが子となる
- 親子関係を壊すような遷移はできない
- `Fiber#resume` -> コンテキストを子へ切り替える
- `Fiber.yield` -> コンテキストを親へ切り替える
- 親ファイバーへコンテキストを切り替えた時点で親子関係は解消される

## ファイバーの生成
- `.new` - ファイバーを生成する
  - 生成された時点では処理を開始せず、`#resume`を呼ばれたタイミングで処理を開始する

## ファイバーのコンテキスト切り替え(親 -> 子)
- `#resume` - `#resume`を呼ぶと`#resume`を呼ばれたファイバー(子)に制御が移る
  - 子は自らの処理の中で何度でも`Fiber.yield`を呼べる

## ファイバーのコンテキスト切り替え(子 -> 親)
- `.yield` - 子ファイバーの中で`.yield`を呼ぶと`#resume`を呼んだファイバー(親)に制御が戻る