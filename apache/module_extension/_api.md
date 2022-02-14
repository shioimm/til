# API
```c
// Apache拡張内で使うデータのための領域をメモリプールに割り当てる

#include "apr_pools.h"
APR_DECLARE(void *)
apr_pcalloc(apr_pool_t *p, apr_size_t size);
```

```c
// cv->server->module_configからサーバー設定を取得する

#include "http_config.h"
APR_DECLARE(void *)
ap_get_module_config(const ap_conf_vector_t *cv, const module *m);

// ap_conf_vector_t - 設定一般
```
