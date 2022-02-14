# ディレクティブの宣言
```c
// 設定ファイルから設定を更新するためのディレクティブを宣言

static const command_rec module_cmds[] = {
  // 引数をON/OFFの一つだけ取るディレクティブを宣言
  AP_INIT_FLAG("miniMrubyEnable",
               set_minim_handler_enable,
               NULL,
               RSRC_CONF,
               "Enable minimruby.");
  // 引数を一つだけ取るディレクティブを宣言
  AP_INIT_TAKE1("miniMrubyCode",
                set_minim_handler_inline,
                NULL,
                ACCESS_CONF,
                "Set mruby code to eval");
  { NULL } // 番兵
};

// ディレクティブを宣言するためのマクロに渡す引数
// 1. ディレクティブの設定ファイル上の名前
// 2. ディレクティブを宣言された時にフックする関数
// 3. 共通設定へのポインタ (NULL値可)
// 4. どのコンテキストで利用できるか
// 5. 説明文言
}
```

#### `minim_enabled`を設定する関数
```c
static const char *set_minim_handler_enable(cmd_parms *cmd, void *mconfig, int flag)
{
  minim_config_t *conf = (minim_config_t *)ap_get_module_config(cmd->server->module_config,
                                                                &minimruby_module);
  conf->minim_enabled = flag;
  return NULL;
}
```

#### `minim_handler_code`を設定する関数
```c
static const char *set_minim_handler_inline(cmd_parms *cmd, void *mconfig, char *arg)
{
  #define CODE_MAX 32768
  minim_dir_config_t *dir_conf = (minim_dir_config_t *)mconfig;
  size_t len = (size_t)strlen(arg) + 1;

  if (len > CODE_MAX) {
    len = CODE_MAX
  }

  dir_conf->minim_handler_code = apr_pcalloc(cmd->pool, len);
  strncpy(dir_conf->minim_handler_code, arg, len);
  return NULL;
}
```

## 引用・参照
- Webで使えるmrubyシステムプログラミング入門 Section 032
