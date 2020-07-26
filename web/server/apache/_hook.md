# フック
- 参照: [モジュールの Apache 1.3 から Apache 2.0 への移植](https://httpd.apache.org/docs/2.4/ja/developer/modules.html)
- 参照: []()

## TL;DR
- Apacheはレスポンスを返すまでの一連の処理の流れの中に多数のフックポイントを持つ
- Apacheはフックポイントにおいて作成した関数を呼び出す
- どの関数をどのフックのハンドラとして利用するかを`static void register_hooks(void)`関数で登録する
- `static void register_hooks(void)`関数はモジュール内に記述する

## フックポイント
- 設定初期化時のフック
- プロセス初期化時のフック
- リクエスト時のフック

## 実行順序
- フックは次の順序クラスのうちどれかに所属するよう登録される
1. `HOOK_FIRST`
2. `HOOK_MIDDLE`
3. `HOOK_LAST`

## フック型
- フックポイントごとのフックの返り値の取り扱いに関する情報を表す
  - `VOID`      -> 登録された全てのフックを実行する
  - `RUN_ALL`   -> 実行したフックがエラーを返さない限り、次のフックを実行する
  - `RUN_FIRST` -> 実行したフックがエラーを返さない限り、次のフックを実行しない

## 返り値
- フックはステータスコードを表す定数を返す
  - `OK`                         - 0
  - `DECLINED`                   - -1
  - `HTTP_OK`                    - 200
  - `HTTP_MOVED_PERMANENTLY`     - 301
  - `HTTP_MOVED_TEMPORARILY`     - 302
  - `HTTP_BAD_REQUEST`           - 400
  - `HTTP_UNAUTHORIZED`          - 401
  - `HTTP_FORBIDDEN`             - 403
  - `HTTP_NOT_FOUND`             - 404
  - `HTTP_INTERNAL_SERVER_ERROR` - 500
  - `HTTP_SERVICE_UNAVAILABLE`   - 503
