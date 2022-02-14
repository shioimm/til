# フックの登録
```c
// フックを登録する関数
static void resister_hooks(apr_pool_t *p)
{
  ap_hook_handler(minim_handler_inline, NULL, NULL, APR_HOOK_MIDDLE);
}
```

#### `minim_handler_inline`
```c
static int minim_handler_inline(request_rec *r)
{
  minim_dir_config_t *dir_conf = ap_get_module_config(r->per_dir_config, &minimruby_module);
  minim_config_t *conf = ap_get_module_config(r->server->module_config, &minimruby_module);

  if (!conf->minim_enabled) {
    return DECLINED;
  }
  if (!dir_conf->minim_handler_code) {
    return DECLINED;
  }

  ap_set_content_type(r, "text/plain");
  ap_rprintf(r, "My First Apache Module!\n");
  ap_rprintf(r, "Code: %s\n", dir_conf->minim_handler_code);

  return OK;
}
```

## 引用・参照
- Webで使えるmrubyシステムプログラミング入門 Section026 / 031
