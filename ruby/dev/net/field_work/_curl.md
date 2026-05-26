# curl
https://github.com/curl/curl/tree/master

```c
// src/tool_main.c

int main(int argc, char *argv[])
{
  CURLcode result = CURLE_OK;

  tool_init_stderr(); // エラー出力先の初期化

  if (main_checkfds()) { // ファイルディスクリプタの枯渇チェック
    errorf("out of file descriptors");
    return CURLE_FAILED_INIT;
  }

  (void)signal(SIGPIPE, SIG_IGN); // SIGPIPEを無視 (パイプ先が閉じられてもプロセスが落ちないようにする)

  /* Initialize memory tracking */
  memory_tracking_init(); // デバッグ用メモリトラッキングの初期化

  /* Initialize the curl library - do not call any libcurl functions before this point */
  result = globalconf_init(); // => globalconf_init (src/tool_cfgable.c) libcurlの初期化

  if(!result) {
    /* Start our curl operation */
    // WIP
    result = operate(argc, argv); // 実際の処理

    /* Perform the main cleanup */
    globalconf_free(); // 確保したグローバルリソースの解放
  }

  return (int)result; // CURLcodeをプロセスの終了コードとして返す
}
```

### libcurlの初期化

```c
// src/tool_cfgable.c

CURLcode globalconf_init(void)
{
  CURLcode result = CURLE_OK; // 0 = 成功 / 0以外 = 何らかのエラー
  global = &globalconf; // struct GlobalConfigのグローバルポインタの設定

  /* Initialize the global config */
  // GlobalConfigのデフォルト値を設定
  global->showerror     = FALSE; /* show errors when silent */
  global->styled_output = TRUE;  /* enable detection */
  global->parallel_max  = PARALLEL_DEFAULT; // 並列転送の最大数

  /* Allocate the initial operate config */
  global->first = global->last = config_alloc();

  if (global->first) {
    /* Perform the libcurl initialization */
    // プロセス起動時に一度だけライブラリ全体を初期化
    result = curl_global_init(CURL_GLOBAL_DEFAULT);
    // => curl_global_init (lib/easy.c) -> global_init (lib/easy.c)
    //    - SSLバックエンドの初期化
    //    - QUICバックエンドの初期化
    //    - Win32 / AmigaOS / macOS環境固有の初期化
    //    - 非同期DNSリゾルバの初期化 (=> Curl_async_global_init - lib/asyn-ares.c or lib/asyn-thrdd.c)
    //    - SSHライブラリの初期化
    //    - フラグの保存

    if (result) {
      errorf("error initializing curl library");
      curlx_free(global->first);
    } else {
      /* Get information about libcurl */
      // - libcurlのランタイム情報を取得してグローバル変数に保存
      // - プロトコルのインデックスを構築
      // - フィーチャーフラグのセット
      result = get_libcurl_info(); // => src/tool_libinfo.c

      if (result) {
        errorf("error retrieving curl library information");
        curlx_free(global->first);
      }
    }
  } else { // config_alloc() に失敗
    errorf("error initializing curl");
    result = CURLE_FAILED_INIT;
  }

  return result;
}
```

### 非同期DNSリゾルバの初期化
- デフォルトはブロッキングDNS、ビルドオプションを指定してコンパイルすることで非同期DNSを利用できる

#### lib/asyn-ares.c

```c
// lib/asyn-ares.c
// USE_RESOLV_ARES (c-aresを用いる方式) が有効な場合

int Curl_async_global_init(void)
{
  #ifdef CARES_HAVE_ARES_LIBRARY_INIT
  if(ares_library_init(ARES_LIB_INIT_ALL)) {
    // => ares_library_init c-arsのAPI
    // ARES_LIB_INIT_ALL ... すべての初期化を行う
    return CURLE_FAILED_INIT;
  }
  #endif

  ares_version(&ares_ver);
  return CURLE_OK;
}
```

#### lib/asyn-thrdd.c

```c
// lib/asyn-thrdd.c
// USE_RESOLV_THREADED (OS標準のgetaddrinfo() を別スレッドで呼ぶ方式) が有効な場合

int Curl_async_global_init(void)
{
  #if defined(USE_ARES) && defined(CARES_HAVE_ARES_LIBRARY_INIT)
  if(ares_library_init(ARES_LIB_INIT_ALL)) {
    // => ares_library_init c-arsのAPI
    // ARES_LIB_INIT_ALL ... すべての初期化を行う
    return CURLE_FAILED_INIT;
  }
  #endif

  return CURLE_OK;
}

```

### 本処理

```c
// WIP
CURLcode operate(int argc, argv_item_t argv[])
{
  CURLcode result = CURLE_OK;
  const char *first_arg;
  char *curlrc_path = NULL;
  bool found_curlrc = FALSE;

  first_arg = argc > 1 ? convert_tchar_to_UTF8(argv[1]) : NULL;

#ifdef HAVE_SETLOCALE
  /* Override locale for number parsing (only) */
  setlocale(LC_ALL, "");
  setlocale(LC_NUMERIC, "C");
#endif

  /* Parse .curlrc if necessary */
  if((argc == 1) ||
     (first_arg && strncmp(first_arg, "-q", 2) &&
      strcmp(first_arg, "--disable"))) {
    if(!parseconfig(NULL, CONFIG_MAX_LEVELS, &curlrc_path))
      found_curlrc = TRUE;

    /* If we had no arguments then make sure a URL was specified in .curlrc */
    if((argc < 2) && (!global->first->url_list)) {
      helpf(NULL);
      result = CURLE_FAILED_INIT;
    }
  }

  unicodefree(CURL_UNCONST(first_arg));

  if(!result) {
    /* Parse the command line arguments */
    ParameterError err = parse_args(argc, argv);
    if(found_curlrc) {
      /* After parse_args so notef knows the verbosity */
      notef("Read config file from '%s'", curlrc_path);
    }
    if(err) {
      result = CURLE_OK;

      /* Check if we were asked for the help */
      if(err == PARAM_HELP_REQUESTED)
        ; /* already done */
      /* Check if we were asked for the manual */
      else if(err == PARAM_MANUAL_REQUESTED) {
#ifdef USE_MANUAL
        hugehelp();
#else
        warnf("built-in manual was disabled at build-time");
#endif
      }
      /* Check if we were asked for the version information */
      else if(err == PARAM_VERSION_INFO_REQUESTED)
        tool_version_info();
      /* Check if we were asked to list the SSL engines */
      else if(err == PARAM_ENGINES_REQUESTED)
        tool_list_engines();
      /* Check if we were asked to dump the embedded CA bundle */
      else if(err == PARAM_CA_EMBED_REQUESTED) {
#ifdef CURL_CA_EMBED
        curl_mprintf("%s", curl_ca_embed);
#endif
      }
      else if(err == PARAM_LIBCURL_UNSUPPORTED_PROTOCOL)
        result = CURLE_UNSUPPORTED_PROTOCOL;
      else if(err == PARAM_READ_ERROR)
        result = CURLE_READ_ERROR;
      else
        result = CURLE_FAILED_INIT;
    }
    else {
      if(global->libcurl) {
        /* Initialize the libcurl source output */
        result = easysrc_init();
      }

      /* Perform the main operations */
      if(!result) {
        size_t count = 0;
        struct OperationConfig *operation = global->first;
        CURLSH *share = curl_share_init();
        if(!share) {
          if(global->libcurl) {
            /* Cleanup the libcurl source output */
            easysrc_cleanup();
          }
          result = CURLE_OUT_OF_MEMORY;
        }

        if(!result)
          result = share_setup(share);

        if(!result && global->ssl_sessions && feature_ssls_export)
          result = tool_ssls_load(global->first, share,
                                  global->ssl_sessions);

        if(!result) {
          /* Get the required arguments for each operation */
          do {
            result = get_args(operation, count++);

            operation = operation->next;
          } while(!result && operation);

          if(!result) {
            /* Set the current operation pointer */
            global->current = global->first;

            /* now run! */
            result = run_all_transfers(share, result);

            if(global->ssl_sessions && feature_ssls_export) {
              CURLcode r2 = tool_ssls_save(global->first, share,
                                           global->ssl_sessions);
              if(r2 && !result)
                result = r2;
            }
          }
        }

        curl_share_cleanup(share);
        if(global->libcurl) {
          /* Cleanup the libcurl source output */
          easysrc_cleanup();

          /* Dump the libcurl code if previously enabled */
          dumpeasysrc();
        }
      }
      else
        errorf("out of memory");
    }
  }
  curlx_free(curlrc_path);
  varcleanup();

  return result;
}
```
