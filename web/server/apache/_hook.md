# フック
- 参照: [モジュールの Apache 1.3 から Apache 2.0 への移植](https://httpd.apache.org/docs/2.4/ja/developer/modules.html)

## TL;DR
- Apacheは作成した関数を呼び出すために一連のフックを使用する
- フックは`static void register_hooks(void)`関数によって登録する

## フックポイント
- 設定初期化時のフック
- プロセス初期化時のフック
- リクエスト時のフック

## 実行順序
1. `HOOK_FIRST`
2. `HOOK_MIDDLE`
3. `HOOK_LAST`

## フック型
- フックの返り値の取り扱いに関する情報を表す
  - `VOID`      -> 登録された全てのフックを実行する
  - `RUN_ALL`   -> 実行したフックがエラーを返さない限り、次のフックを実行する
  - `RUN_FIRST` -> 実行したフックがエラーを返さない限り、次のフックを実行しない
