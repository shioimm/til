# モジュールの宣言
- ` module AP_MODULE_DECLARE_DATA`の構造に沿って必要な関数・変数の定義を行う

```c
#define CORE_PRIVATE
#include "httpd.h"
#include "http_config.h"
#include "http_protocol.h"
#include "http_log.h"

module AP_MODULE_DECLINE_DATA minimruby_module;

module AP_MODULE_DECLARE_DATA minimruby_module = {
  STANDARD20_MODULE_STUFF,
  minim_create_dir_config,
  NULL,
  minim_create_config,
  NULL,
  module_cmds,
  resister_hooks
};

// 1. STANDARD20_MODULE_STUFF (拡張モジュールの形式)
// 2. ディレクトリ単位の設定を初期化するための関数ポインタ
// 3. ディレクトリ単位の設定をマージするための関数 (NULL値可)
// 4. サーバー単位の設定を初期化するための関数ポインタ
// 5. サーバー単位の設定をマージするための関数 (NULL値可)
// 6. 設定ファイル上でどのようなディレクティブを定義するかについての記述
//    command_rec構造体の配列
// 7. どの関数をそのフックのハンドラとして利用するかについての定義
//    ap_hook_handlerを呼び出す関数
```

#### ディレクトリ単位の設定を初期化するための関数
```c
// アクセスしたらどのようなmrubyのコードを実行するかを示す構造体
typedef struct minim_dir_config {
  char *minim_handler_code;
} minim_dir_config_t;

// ディレクトリ単位の設定を初期化するための関数
// minim_dir_config_t構造体を割り当てて初期化
static void *minim_create_dir_config(apr_pool_t *p, char *_dirname)
{
  minim_dir_config_t *conf = (minim_dir_config_t *)apr_pcalloc(p, sizeof(minim_dir_config_t));
  conf->minim_handler_code = NULL;
  return conf;
}
```

#### サーバー単位の設定を初期化するための関数
```c
// サーバー全体の情報としてmod_minimrubyが有効か無効かを示す構造体
typedef struct minim_config {
  unsigned int minim_enabled;
} minim_config_t;

// サーバー単位の設定を初期化するための関数
// minim_config_t構造体を割り当てて初期化
static void *minim_create_config(apr_pool_t *p, server_rec *server)
{
  minim_config_t *conf = (minim_config_t *)apr_pcalloc(p, sizeof(minim_config_t));
  conf->minim_enabled = 0;
  return conf;
}
```


#### `command_rec`構造体
- 設定ファイル上で呼ばれるディレクティブの名前と、ディレクティブ宣言時にフックする関数を設定する構造体

#### `ap_hook_handler`関数
- モジュール内に記述した関数をフックのハンドラとして登録する関数

## 引用・参照
- Webで使えるmrubyシステムプログラミング入門 Section 032
