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
// src/tool_operate.c

CURLcode operate(int argc, argv_item_t argv[])
{
  CURLcode result = CURLE_OK;
  const char *first_arg;
  char *curlrc_path = NULL;
  bool found_curlrc = FALSE;

  // 引数で渡された文字列をUTF-8文字列に変換
  // argv_item_tはプラットフォームによって型が異なる
  first_arg = argc > 1 ? convert_tchar_to_UTF8(argv[1]) : NULL;

  #ifdef HAVE_SETLOCALE
  // ロケールの設定
  /* Override locale for number parsing (only) */
  setlocale(LC_ALL, "");
  setlocale(LC_NUMERIC, "C");
  #endif

  /* Parse .curlrc if necessary */
  // .curlrcの読み込み
  // .curlrcには接続、認証、TLS/SSL、HTTP、出力、転送、設定ファイルなどに関する設定を記述できる
  if((argc == 1) || (first_arg && strncmp(first_arg, "-q", 2) && strcmp(first_arg, "--disable"))) {
    if(!parseconfig(NULL, CONFIG_MAX_LEVELS, &curlrc_path)) {
        found_curlrc = TRUE;
    }

    /* If we had no arguments then make sure a URL was specified in .curlrc */
    if((argc < 2) && (!global->first->url_list)) {
      helpf(NULL);
      result = CURLE_FAILED_INIT;
    }
  }

  // first_argの解放
  unicodefree(CURL_UNCONST(first_arg));

  if (!result) { // .curlrcの読み込みに成功
    /* Parse the command line arguments */
    // コマンドライン引数のパース
    ParameterError err = parse_args(argc, argv);

    if (found_curlrc) {
      /* After parse_args so notef knows the verbosity */
      notef("Read config file from '%s'", curlrc_path);
    }

    if (err) { // コマンドライン引数のパースに失敗
      result = CURLE_OK;

      if (err == PARAM_HELP_REQUESTED) {
        /* Check if we were asked for the help */
        // ヘルプを出力 (--help / -h)
        ; /* already done */
      } else if(err == PARAM_MANUAL_REQUESTED) {
        /* Check if we were asked for the manual */
        // マニュアルを出力 (--manual / -M)
        #ifdef USE_MANUAL
        hugehelp();
        #else
        warnf("built-in manual was disabled at build-time");
        #endif
      } else if (err == PARAM_VERSION_INFO_REQUESTED) {
        /* Check if we were asked for the version information */
        // バージョン・機能一覧を出力 (--version / -V)
        tool_version_info();
      } else if (err == PARAM_ENGINES_REQUESTED) {
        /* Check if we were asked to list the SSL engines */↲
        // SSLエンジン一覧を出力 (--engine list)
        tool_list_engines();
      } else if (err == PARAM_CA_EMBED_REQUESTED) {
        /* Check if we were asked to dump the embedded CA bundle */
        // ビルド時に埋め込んだCAバンドルを出力 (--ca-native)
        #ifdef CURL_CA_EMBED
        curl_mprintf("%s", curl_ca_embed);
        #endif
      } else if (err == PARAM_LIBCURL_UNSUPPORTED_PROTOCOL) {
        // ビルドに含まれないプロトコル指定を指定した場合
        result = CURLE_UNSUPPORTED_PROTOCOL;
      } else if (err == PARAM_READ_ERROR) {
        // 設定ファイルの読み込みに失敗した場合
        result = CURLE_READ_ERROR;
      } else {
        // それ以外のエラーの場合
        result = CURLE_FAILED_INIT;
      }

    } else {

      /* Initialize the libcurl source output */
      // --libcurl <ファイル名> オプションありの場合:
      // curlが行う処理と同等の処理を記述したCソースコードを生成し、指定のファイルに書き出す
      if (global->libcurl) result = easysrc_init();

      /* Perform the main operations */
      if (!result) {
        // 実行したリクエスト数を数えるカウンタ
        size_t count = 0;

        // .curlrcやコマンドライン引数から構築された操作設定のリンクリストの先頭要素
        struct OperationConfig *operation = global->first;

        // 複数のcurl_easyハンドル (1回のリクエストに必要な状態を持つオブジェクト) 間で共有するデータ
        // = CURLSHハンドルの初期化
        // e.g. Cookie、DNSキャッシュ、SSLセッション、Public Suffix List、HSTS ポリシー、接続キャッシュなど
        CURLSH *share = curl_share_init(); // => curl_share_init (lib/curl_share.c)

        if (!share) { // メモリ確保に失敗した場合
          if (global->libcurl) easysrc_cleanup(); /* Cleanup the libcurl source output */

          result = CURLE_OUT_OF_MEMORY;
        }

        // CURLSHハンドルで共有する対象をセットアップ
        if (!result) result = share_setup(share); // => share_setup (src/tool_operate.c)

        // --ssl-sessions <ファイル> オプションあり、
        // かつlibcurlがSSLセッションエクスポート機能付きでビルドされている場合:
        // 指定ファイルから前回保存したTLS セッションチケットを読み込み、CURLSHにセットする
        // -> 次回の接続でTLSハンドシェイクを省略して高速化する
        if (!result && global->ssl_sessions && feature_ssls_export) {
          result = tool_ssls_load(global->first, share, global->ssl_sessions);
        }

        if (!result) {
          /* Get the required arguments for each operation */
          do {
            // OperationConfigのリンクリストを先頭から順に走査し、各操作に対してget_args()を呼ぶ
            result = get_args(operation, count++); // => get_args (src/tool_paramhlp.c) 転送前の補完処理を行う

            operation = operation->next;
          } while(!result && operation);

          if (!result) {
            /* Set the current operation pointer */
            // global->currentをリストの先頭に戻す
            global->current = global->first;

            /* now run! */
            // 全URLの転送を実行
            result = run_all_transfers(share, result); // => run_all_transfers (src/tool_operate.c)

            // SSL セッションの保存
            if (global->ssl_sessions && feature_ssls_export) {
              CURLcode r2 = tool_ssls_save(global->first, share, global->ssl_sessions);

              if(r2 && !result) result = r2;
          }
        }

        // CURLSHのクリーンアップ
        curl_share_cleanup(share); // => curl_share_cleanup (lib/curl_share.c)

        // --libcurl <ファイル> が指定されていた場合のコード出力
        if(global->libcurl) {
          /* Cleanup the libcurl source output */
          easysrc_cleanup(); // => easysrc_cleanup (src/tool_easysrc.c)

          /* Dump the libcurl code if previously enabled */
          dumpeasysrc(); // => dumpeasysrc (src/tool_easysrc.c)
        }
      } else {
        errorf("out of memory");
      }
    }
  }

  curlx_free(curlrc_path); // (lib/curlx/fopen.c) 設定ファイルパスの解放
  varcleanup(); // => varcleanup (src/var.c) --variable name=value で定義したユーザー変数のリンクリストを解放

  return result;
}
```

#### `run_all_transfers`

```c
// src/tool_operate.c

static CURLcode run_all_transfers(CURLSH *share, CURLcode result)
{
  /* Save the values of noprogress and isatty to restore them later on */
  bool orig_noprogress = (bool)global->noprogress;
  bool orig_isatty = (bool)global->isatty;
  struct per_transfer *per;

  /* Time to actually do the transfers */
  if(!result) {
    if(global->parallel)
      result = parallel_transfers(share);
    else
      result = serial_transfers(share);
  }

  /* cleanup if there are any left */
  for(per = transfers; per;) {
    bool retry;
    uint32_t delay;
    CURLcode result2 = post_per_transfer(per, result, &retry, &delay);
    if(!result)
      /* do not overwrite the original error */
      result = result2;

    /* Free list of given URLs */
    clean_getout(per->config);

    per = del_per_transfer(per);
  }

  /* Reset the global config variables */
  global->noprogress = orig_noprogress;
  global->isatty = orig_isatty;

  return result;
}
```
