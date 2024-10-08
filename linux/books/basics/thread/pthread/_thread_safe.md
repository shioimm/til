# スレッドセーフ
- 参照: Linuxプログラミングインターフェース 31章

## リエントラントな関数
- 同時に複数のスレッドから実行された際、
  他のスレッドの状態に関わらず期待通りの結果が保証される関数
- グローバル変数・スタティック変数を操作しない

## シリアライズ(逐次実行)
- 一度に一スレッドのみがその関数を実行できるような状況
  並列実行が不可能になり、並行性が損なわれる
- mutexにより、保護する範囲を関数単位からクリティカルセクション単位へ
  置き換えることによって平行性を改善することができる

## ワンタイムイニシャライゼーション
- コールしたスレッドに関わらず、最初に実行された際のみ実行する初期化関数
- `pthread_once(3)`で指定する

## スレッド固有データ(TSD)
- スレッドとメモリ領域を対応付ける機能
- 関数が使用する変数をスレッドごとに割り当てられる
- 関数の実行が終わっても永続的に存在し続ける

### ライブラリ関数との関係
- スレッドに対応するメモリ領域を割り当てるのはライブラリ関数
  - そのスレッドから最初に関数を実行した際に割り当てる
  - 同じスレッドから関数を実行すると、割り当て済みのメモリ領域を使用する
- スレッド固有データはライブラリ関数別に割り当て可能
  - 関数自身に対応するスレッド固有データと他の関数用のスレッド固有データを
    区別するキーが必要
- ライブラリ関数はスレッドの終了タイミングを直接制御することはない
  - スレッド終了時にはスレッド固有データのために割り当てたメモリ領域を
    ダイナミックに解放する仕組み(デストラクタ)が必要

### スレッド固有データの利用手順
1. `pthread_key_create(3)`によりキーを作成
2. キーに対応するメモリ領域を解放するデストラクタを設定
3. 自スレッド用のスレッド固有データのメモリ領域を割り当てる
4. `pthread_setspecific(3)` / `pthread_getspecific(3)`により
   割り当てたメモリ領域を管理する

### スレッド固有データの実装
- グローバル配列`pthread_keys`(プロセスごとに一つの配列)
  - インデックス - スレッド固有データのキー
  - 要素 - `使用中フラグ` / `デストラクタ`を持つ構造体
- スレッド別の配列
  - インデックス - スレッド固有データのキー
  - 要素 - `pthread_setspecific(3)`に指定されたポインタ

### 対応可能なキー数
- SUSv3では128を下限としている(`_POSIX_THREAD_KEYS_MAX`)
- Linuxでは1024まで対応している

## スレッドローカルストレージ(TLS)
- スレッドごとの専用メモリ領域を実現する
- スレッドローカルストレージとして宣言した変数はスレッドごとに専用の変数となる
  スレッドが終了すると自動的に破棄される

### スレッドローカルストレージの使用方法
- グローバル・スタティック変数に`__thread`修飾子を加える
- `static` / `extern`を用いる場合、`__thread`修飾子はその後につける
- 通常のグローバル / スタティック変数宣言と同様の初期値式を記述できる
- アドレス演算子`&` でスレッドローカルストレージ変数のアドレスが得られる
