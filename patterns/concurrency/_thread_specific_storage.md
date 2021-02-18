# Thread-Specific Storage
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第11章

## TL;DR
- Clientスレッドごとに固有のThread-Specific Object領域を確保する
- スレッドをキーとしてスレッド固有のオブジェクトにアクセスするためのパターン
  - スレッド固有のオブジェクト = 複数のスレッドで共有されないオブジェクト
  - スレッドにコンテキストを導入する

## 要素
### Client
- Thread-Specific ObjectProxyに対して処理を依頼する
- 複数のClientが一つのThread-Specific ObjectProxyを使用する

### Thread-Specific ObjectProxy
- 複数のClientから依頼された処理を実行する
- Thread-Specific ObjectCollectionを利用して
  各Clientに対応するThread-Specific Objectを取得する
- 実際の処理をThread-Specific Objectに移譲する

### Thread-Specific ObjectCollection
- ClientとThread-Specific Objectの対応付けを行う
  - Clientに対応するThread-Specific Objectを返す
  - Clientに対応するThread-Specific Objectを追加する

### Thread-Specific Object
- スレッドの固有の情報を保持するオブジェクト(インスタンス)
- ClientからThread-Specific ObjectProxyとThread-Specific ObjectCollectionを通じて
  シングルスレッドで呼び出される
- スレッド自身の局所変数以外にスレッド固有のメモリ領域を確保するために使用される
  - 局所変数 - スレッド内にあるスレッド固有の領域
  - Thread-Specific Object - スレッド外にあるスレッド固有の領域

## 再利用性
- 排他制御が隠蔽されることによって再利用性を高めている

## 関連するパターン
- Singleton
- Worker Thread
- Single Threaded Execution
- Proxy
