# フック
- Apacheはレスポンスを返すまでの一連の処理の流れの中に多数のフックポイントを持つ
- Apacheの拡張モジュールはフックポイントにおいて任意の処理を呼び出す
- どの処理をどのフックのハンドラとして利用するか
  モジュール内で`static void register_hooks(void)`関数を用いて登録する

#### フックポイント
- 設定初期化時のフック
  - `ap_hook_post_config()`
- プロセス初期化時のフック
  - `ap_hook_child_init()`
- リクエスト時のフック
  - `ap_hook_post_read_request()`
  - `ap_hook_post_quick_handler()`
  - `ap_hook_trabslate_name()`
  - `ap_hook_map_to_storage()`
  - `ap_hook_access_checker()`
  - `ap_hook_check_user_id()`
  - `ap_hook_auth_checker()`
  - `ap_hook_fixups()`
  - `ap_hook_insert_filter()`
  - `ap_hook_handler()`
  - `ap_hook_log_transaction()`

#### 実行順序
- フックは順序クラスのうちどれかに所属するように登録され、所属するクラスの順に実行される
1. `HOOK_FIRST`
2. `HOOK_MIDDLE`
3. `HOOK_LAST`

#### フックの型
- フックポイントごとのフックの返り値の取り扱いに関する情報を表す
  - `VOID`
    - どういう結果であれ登録された全てのフックを実行する
  - `RUN_ALL`
    - 実行したフックが`OK` / `DECLINE`を返した場合、そのフックポイントの次のモジュールの関数を呼ぶ
    - それ以外の値はエラー扱い -> その関数で停止
  - `RUN_FIRST`
    - 実行したフックが`OK`を返した場合、その関数で停止
    - 実行したフックが`DECLINE`を返した場合、そのフックポイントの次のモジュールの関数を呼ぶ
    - それ以外の値はエラー扱い -> その関数で停止

## フック関数
- `request_rec *`型 (リクエストを表現する構造体へのポインタ) を受け取り、
  HTTPステータスコードを定数を返す

#### 返り値

| ステータスコード             | 値  |
| -                            | -   |
| `OK`                         | 0   |
| `DECLINED`                   | -1  |
| `HTTP_OK`                    | 200 |
| `HTTP_MOVED_PERMANENTLY`     | 301 |
| `HTTP_MOVED_TEMPORARILY`     | 302 |
| `HTTP_BAD_REQUEST`           | 400 |
| `HTTP_UNAUTHORIZED`          | 401 |
| `HTTP_FORBIDDEN`             | 403 |
| `HTTP_NOT_FOUND`             | 404 |
| `HTTP_INTERNAL_SERVER_ERROR` | 500 |
| `HTTP_SERVICE_UNAVAILABLE`   | 503 |

## 参照
- [モジュールの Apache 1.3 から Apache 2.0 への移植](https://httpd.apache.org/docs/2.4/ja/developer/modules.html)
- Webで使えるmrubyシステムプログラミング入門 Section027
