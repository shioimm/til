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

struct per_transfer *transfers; /* first node */

static CURLcode run_all_transfers(CURLSH *share, CURLcode result)
{
  /* Save the values of noprogress and isatty to restore them later on */
  bool orig_noprogress = (bool)global->noprogress;
  bool orig_isatty = (bool)global->isatty;

  struct per_transfer *per; // URL1件分の転送の実行時状態を保持する構造体
  // => struct per_transfer (src/tool_operate.h))

  /* Time to actually do the transfers */
  // 転送の実行
  if (!result) {
    // --parallel が指定されたとき...HTTP/2で必要
    if (global->parallel) {
      result = parallel_transfers(share); // => parallel_transfers (src/tool_operate.c)
    } else {
      result = serial_transfers(share); // => serial_transfers (src/tool_operate.c)
    }
  }

  /* cleanup if there are any left */
  // クリーンアップ
  for (per = transfers; per;) {
    bool retry;
    uint32_t delay;

    // 各転送の後処理
    CURLcode result2 = post_per_transfer(per, result, &retry, &delay); // => post_per_transfer (src/tool_operate.c)

    if (!result) {
      /* do not overwrite the original error */
      result = result2;
    }

    /* Free list of given URLs */
    // OperationConfigが持つURLリストを解放
    clean_getout(per->config); // => clean_getout (src/tool_operhlp.c)

    // per_transfer 構造体をリストから外してメモリを解放して次の次のノードを返す
    per = del_per_transfer(per); // => del_per_transfer (src/tool_operate.c)
  }

  /* Reset the global config variables */
  // 転送中に書き換えられたグローバル変数を復元する
  global->noprogress = orig_noprogress;
  global->isatty = orig_isatty;

  return result;
}
```

```c
// struct per_transfer (src/tool_operate.h)

struct per_transfer {
  // 転送失敗時の詳細メッセージを書き込むためのバッファ
  char errorbuffer[CURL_ERROR_SIZE];

  /* double linked */
  // 次の転送へのポインタ
  struct per_transfer *next;
  // 前の転送へのポインタ
  struct per_transfer *prev;
  // この転送に対応する設定
  struct OperationConfig *config; /* for this transfer */
  // 転送後に取得するサーバ証明書情報
  const struct curl_certinfo *certinfo;
  // この転送に利用するeasyハンドル
  CURL *curl;

  /* NULL or malloced */
  // 転送先URL
  char *url;
  // ワイルドカードを展開し複数URLが生成された場合のインデックス
  curl_off_t urlnum; /* the index of the given URL */
  // 出力ファイル名
  char *outfile;
  // プログレスバーの表示状態
  struct ProgressData progressbar;
  // (出力先ストリーム) レスポンスボディの出力先
  struct OutStruct outs;
  // (出力先ストリーム) レスポンスヘッダの出力先
  struct OutStruct heads;
  // (出力先ストリーム) ETagヘッダの保存先
  struct OutStruct etag_save;
  // CURLOPT_HEADERFUNCTIONコールバックに渡すコンテキスト
  struct HdrCbData hdrcbdata;
  // 受信したヘッダの行数
  long num_headers;
  // 直前のヘッダ行が空行 (ヘッダ終端) だったか
  BIT(was_last_header_empty);
  // (ファイルアップロード) -T で指定するアップロードファイル名
  char *uploadfile;
  // (ファイルアップロード) アップロード元のファイルディスクリプタ
  int infd;

  // この転送を開始した時刻
  struct curltime start; /* start of this transfer */
  // (リトライ) 最後にリトライを開始した時刻
  struct curltime retrystart;
  // (リトライ) 並列転送でのリトライ時に再送を開始する時刻
  time_t startat; /* when doing parallel transfers, this is a retry transfer
                     that has been set to sleep until this time before it
                     should get started (again) */
  // (リトライ) 残りのリトライ可能回数
  long retry_remaining;
  // (リトライ) 実際にリトライした回数
  long num_retries; /* counts the performed retries */
  // (リトライ) リトライ待機時間のデフォルトms
  uint32_t retry_sleep_default;
  // (リトライ) 次のリトライまでの待機ms
  uint32_t retry_sleep;

  /* for parallel progress bar */
  // (並列転送用プログレスバー) ダウンロード総バイト数
  curl_off_t dltotal;
  // (並列転送用プログレスバー) ダウンロード済みバイト数
  curl_off_t dlnow;
  // (並列転送用プログレスバー) アップロード総バイト数
  curl_off_t ultotal;
  // (並列転送用プログレスバー) アップロード済みバイト数
  curl_off_t ulnow;
  // (並列転送用プログレスバー) dltotalを集計済みかどうか
  BIT(dltotal_added); /* if the total has been added from this */
  // (並列転送用プログレスバー) ultotalを集計済みかどうか
  BIT(ultotal_added);

  // (ファイルアップロード) アップロードファイルの予想サイズ
  curl_off_t uploadfilesize; /* expected total amount */
  // (ファイルアップロード) コールバックから送出済みのバイト数
  curl_off_t uploadedsofar; /* amount delivered from the callback */
  // (ファイルアップロード) infdをクローズする必要があるか
  BIT(infdopen); /* TRUE if infd needs closing */

  // この転送でプログレスバーを非表示にするか
  BIT(noprogress);

  // multiハンドルに追加済みか
  BIT(added); /* set TRUE when added to the multi handle */
  // 他の転送で致命的エラーが発生したため中断すべきか
  BIT(abort); /* when doing parallel transfers and this is TRUE then a critical
                 error (eg --fail-early) has occurred in another transfer and
                 this transfer gets aborted in the progress callback */
  // この転送をスキップ済みとみなすか
  BIT(skip);  /* considered already done */
};
```

#### `serial_transfers`

```c
// src/tool_operate.c

static CURLcode serial_transfers(CURLSH *share)
{
  CURLcode returncode = CURLE_OK; // 最終的な返り値
  CURLcode result     = CURLE_OK; // 各操作の一時的な結果
  struct per_transfer *per; // // 転送リストのイテレータ
  bool added   = FALSE; // 転送が実際に追加されたか
  bool skipped = FALSE; // 転送がスキップされたか

  // 次に実行すべき転送を準備する
  result = create_transfer(share, &added, &skipped); // => create_transfer (src/tool_operate.c)

  if (result) return result;

  if (!added) { // URLリストが空
    errorf("no transfer performed");
    return CURLE_READ_ERROR;
  }

  for (per = transfers; per;) {
    bool retry;
    uint32_t delay_ms;
    bool bailout = FALSE;
    struct curltime start;

    // 転送開始時刻
    start = curlx_now();

    if (!per->skip) {
      // アップロードファイルがある場合の準備
      result = pre_transfer(per); // => pre_transfer (src/tool_operate.c)

      if (result) break;

      if (global->libcurl) {
        // --libcurl が指定されている場合、生成するCソースコードに
        // この転送に対応するcurl_easy_perform等の行を追記する
        result = easysrc_perform(); // => easysrc_perform (src/tool_easysrc.c)
        if(result) break;
      }

      // 転送を実行
      result = curl_easy_perform(per->curl); // => curl_easy_perform (lib/easy.c)
    }

    returncode = post_per_transfer(per, result, &retry, &delay_ms);
    if(retry) {
      curlx_wait_ms(delay_ms);
      continue;
    }

    /* Bail out upon critical errors or --fail-early */
    if(is_fatal_error(returncode) || (returncode && global->fail_early))
      bailout = TRUE;
    else {
      do {
        /* setup the next one before we delete this */
        result = create_transfer(share, &added, &skipped);
        if(result) {
          returncode = result;
          bailout = TRUE;
          break;
        }
      } while(skipped);
    }

    per = del_per_transfer(per);

    if(bailout)
      break;

    if(per && global->ms_per_transfer) {
      /* how long time did the most recent transfer take in number of
         milliseconds */
      timediff_t milli = curlx_timediff_ms(curlx_now(), start);
      if(milli < global->ms_per_transfer) {
        notef("Transfer took %" CURL_FORMAT_CURL_OFF_T " ms, "
              "waits %ldms as set by --rate",
              milli, (long)(global->ms_per_transfer - milli));
        /* The transfer took less time than wanted. Wait a little. */
        curlx_wait_ms((long)(global->ms_per_transfer - milli));
      }
    }
  }
  if(returncode)
    /* returncode errors have priority */
    result = returncode;

  if(result)
    single_transfer_cleanup();

  return result;
}
```

#### `parallel_transfers`

```c
// src/tool_operate.c
// WIP

static CURLcode parallel_transfers(CURLSH *share)
{
  CURLcode result;
  struct parastate p;
  struct parastate *s = &p;
  s->share = share;
  s->mcode = CURLM_OK;
  s->result = CURLE_OK;
  s->still_running = 1;
  s->start = curlx_now();
  s->wrapitup = FALSE;
  s->wrapitup_processed = FALSE;
  s->tick = time(NULL);
  s->multi = curl_multi_init();
  if(!s->multi)
    return CURLE_OUT_OF_MEMORY;

  if(TRUE
#ifdef DEBUGBUILD
    && getenv("CURL_QUICK_EXIT")
#endif
    ) {
    /* QUICK_EXIT allows for running threads to be detached and not
     * joined. Preferably in non-debug runs. */
    (void)curl_multi_setopt(s->multi, CURLMOPT_QUICK_EXIT, 1L);
  }
  (void)curl_multi_setopt(s->multi, CURLMOPT_NOTIFYFUNCTION, mnotify);
  (void)curl_multi_setopt(s->multi, CURLMOPT_NOTIFYDATA, s);
  (void)curl_multi_setopt(s->multi, CURLMOPT_MAX_HOST_CONNECTIONS, (long)
                          global->parallel_host);
  (void)curl_multi_notify_enable(s->multi, CURLMNOTIFY_INFO_READ);

  result = add_parallel_transfers(s->multi, s->share,
                                  &s->more_transfers, &s->added_transfers);
  if(result) {
    curl_multi_cleanup(s->multi);
    return result;
  }

#ifdef DEBUGBUILD
  if(global->test_event_based)
#ifdef USE_LIBUV
    return parallel_event(s);
#else
    errorf("Testing --parallel event-based requires libuv");
#endif
  else
#endif

  if(all_added) {
    while(!s->mcode && (s->still_running || s->more_transfers)) {
      /* If stopping prematurely (eg due to a --fail-early condition) then
         signal that any transfers in the multi should abort (via progress
         callback). */
      if(s->wrapitup) {
        if(!s->still_running)
          break;
        if(!s->wrapitup_processed) {
          struct per_transfer *per;
          for(per = transfers; per; per = per->next) {
            if(per->added)
              per->abort = TRUE;
          }
          s->wrapitup_processed = TRUE;
        }
      }
      else if(s->more_transfers) {
        s->result = add_parallel_transfers(s->multi, s->share,
                                           &s->more_transfers,
                                           &s->added_transfers);
        if(s->result)
          break;
      }

      s->mcode = curl_multi_poll(s->multi, NULL, 0, 1000, NULL);
      if(!s->mcode)
        s->mcode = curl_multi_perform(s->multi, &s->still_running);

      progress_meter(s->multi, &s->start, FALSE);
    }

    (void)progress_meter(s->multi, &s->start, TRUE);
  }

  /* Result is the first failed transfer - if there was one. */
  result = s->result;

  /* Make sure to return some kind of error if there was a multi problem */
  if(s->mcode) {
    result = (s->mcode == CURLM_OUT_OF_MEMORY) ? CURLE_OUT_OF_MEMORY :
      /* The other multi errors should never happen, so return
         something suitably generic */
      CURLE_BAD_FUNCTION_ARGUMENT;
  }

  curl_multi_cleanup(s->multi);

  return result;
}
```

#### `create_transfer`

```c
// src/tool_operate.c

static CURLcode create_transfer(CURLSH *share, bool *added, bool *skipped)
{
  CURLcode result = CURLE_OK;
  *added = FALSE;

  while (global->current) {
    result = transfer_per_config(global->current, share, added, skipped);
    // => transfer_per_config (src/tool_operate.c)
    // OperationConfigから転送を準備

    if(!result && !*added) {
      /* when one set is drained, continue to next */
      global->current = global->current->next;
      continue;
    }
    break;
  }
  return result;
}
```

#### `transfer_per_config`

```c
// src/tool_operate.c

static CURLcode transfer_per_config(struct OperationConfig *config, CURLSH *share, bool *added, bool *skipped)
{
  CURLcode result;
  *added = FALSE;

  /* Check we have a URL */
  //  URLの存在を確認
  if (!config->url_list || !config->url_list->url) {
    helpf("(%d) no URL specified", CURLE_FAILED_INIT);
    result = CURLE_FAILED_INIT;
  } else {
    // CA証明書パスの解決
    result = cacertpaths(config); // => cacertpaths (src/tool_operate.c)

    if (!result) {
      // 転送の準備
      result = single_transfer(config, share, added, skipped); // => single_transfer ()

      // 失敗時のクリーンアップ
      if (!*added || result) single_transfer_cleanup();
    }
  }

  return result;
}
```

#### `single_transfer `

```c
// src/tool_operate.c
// 1つのOperationConfigからHTTPメソッドを確定させ、転送の準備を整えてcreate_singleに渡す

static CURLcode single_transfer(struct OperationConfig *config, CURLSH *share, bool *added, bool *skipped)
{
  CURLcode result = CURLE_OK;
  struct State *state = &global->state;
  char *httpgetfields = config->httpgetfields;

  *skipped = *added = FALSE; /* not yet */

  // HTTPメソッドを確定させる
  if (config->postfields) {
    if (config->use_httpget) {
      if (!httpgetfields) {
        /* Use the postfields data for an HTTP get */
        httpgetfields = config->httpgetfields = config->postfields;
        config->postfields = NULL;

        if (SetHTTPrequest((config->no_body ? TOOL_HTTPREQ_HEAD : TOOL_HTTPREQ_GET), &config->httpreq)) {
          return CURLE_FAILED_INIT;
        }
      }
    } else if (SetHTTPrequest(TOOL_HTTPREQ_SIMPLEPOST, &config->httpreq))
      return CURLE_FAILED_INIT;
    }
  }

  if(!httpgetfields) config->httpgetfields = config->query;

  // クライアント証明書タイプを確定させる
  result = set_cert_types(config);

  if(result) return result;

  // URLノードの初期化
  if (!state->urlnode) {
    /* first time caller, setup things */
    state->urlnode = config->url_list;
    state->upnum = 1;
  }

  return create_single(config, share, state, added, skipped); // => create_single (src/tool_operate.c)
}
```

#### `create_single`

```c
// src/tool_operate.c
// URLノード (getout) ごとにeasyハンドルを生成し、per_transferを1件構築し
// *added = TRUEをセットしてループを終了

static CURLcode create_single(
  struct OperationConfig *config,
  CURLSH *share,
  struct State *state,
  bool *added,
  bool *skipped
) {
  const bool orig_isatty     = (bool)global->isatty;
  const bool orig_noprogress = (bool)global->noprogress;
  CURLcode result = CURLE_OK;

  while (state->urlnode) {
    struct per_transfer *per = NULL;
    struct OutStruct *outs;
    struct OutStruct *heads;
    struct OutStruct etag_first;
    CURL *curl;
    struct getout *u = state->urlnode;
    FILE *err = (!global->silent || global->showerror) ? tool_stderr : NULL;
    bool break_loop = FALSE;

    // --- URLノードの確認 ---
    if(!u->url) {
      /* This node has no URL. End of the road. */
      warnf("Got more output options than URLs");
      break;
    }
    // ----------------------

    // --- アップロードファイルをstate->uploadfileにセット ---
    result = setup_input_file(config, state, u, err);

    if(result) return result;

    if(state->upidx >= state->upnum) {
      state->urlnum = 0;
      curlx_safefree(state->uploadfile);
      glob_cleanup(&state->inglob);
      state->upidx = 0;
      state->urlnode = u->next; /* next node */
      state->upnum = 1;
      continue;
    }
    // -------------------------------------------------------

    // --- URL globの展開 ---
    result = setup_url_pattern(config, state, u, err);
    if (result) return result;
    // ----------------------

    // --- ETagファイルの準備---
    result = setup_etag_files(config, &etag_first, &break_loop);
    if (result || break_loop) return result;
    // -------------------------

    // --- easyハンドルとper_transferの生成 ---
    curl = curl_easy_init();
    result = curl ? add_per_transfer(&per) : CURLE_OUT_OF_MEMORY;

    if (result) {
      curl_easy_cleanup(curl);

      if (etag_first.fopened) curlx_fclose(etag_first.stream);
      return result;
    }
    // ---------------------------------------

    // --- per_transferへの値のセット ---
    per->etag_save = etag_first; /* copy the whole struct */

    if (state->uploadfile) {
      per->uploadfile = curlx_strdup(state->uploadfile);

      if(!per->uploadfile || SetHTTPrequest(TOOL_HTTPREQ_PUT, &config->httpreq)) {
        curlx_safefree(per->uploadfile);
        curl_easy_cleanup(curl);
        return CURLE_FAILED_INIT;
      }
    }

    per->config = config;
    per->curl = curl;
    per->urlnum = u->num;
    // ---------------------------------

    /* default headers output stream is stdout */
    heads = &per->heads;
    heads->stream = stdout;

    /* Single header file for all URLs */
    result = setup_headerfile(config, per, heads);
    if(result) return result;

    // --- 出力先の設定 ---
    outs = &per->outs;

    per->infdopen = FALSE;
    per->infd = STDIN_FILENO;

    /* default output stream is stdout */
    outs->stream = stdout;

    result = select_next_url(state, u, &per->url);
    if (result) return result;
    if (!per->url) break;

    result = setup_outfile(config, per, u, outs, skipped);
    if (result) return result;
    // --------------------

    // --- アップロード転送の設定 ---
    result = setup_transfer_upload(config, per);
    if (result) return result;
    // ------------------------------

    // --- プログレスバーの制御 ---
    if (!outs->out_null && output_expected(per->url, per->uploadfile) &&
       outs->stream && isatty(fileno(outs->stream)))
      /* we send the output to a tty, therefore we switch off the progress
         meter */
      per->noprogress = global->noprogress = global->isatty = TRUE;
    else {
      /* progress meter is per download, so restore config values */
      per->noprogress = global->noprogress = orig_noprogress;
      global->isatty = orig_isatty;
    }
    // ----------------------------

    // --- クエリ文字列の付加 ---
    result = append2query(config, per, config->httpgetfields);
    if (result) return result;
    // --------------------------

    if ((!per->outfile || !strcmp(per->outfile, "-")) &&
       !config->use_ascii) {
      /* We get the output to stdout and we have not got the ASCII/text flag,
         then set stdout to be binary */
      CURL_BINMODE(stdout);
    }

    /* explicitly passed to stdout means okaying binary gunk */
    config->terminal_binary_ok = (per->outfile && !strcmp(per->outfile, "-"));

    // --- ヘッダコールバックの設定 ---
    setup_header_cb(config, &per->hdrcbdata, u, outs, heads, &etag_first);
    // --------------------------------

    // --- libcurlへのオプション設定 ---
    result = config2setopts(config, per, curl, share);
    if (result) return result;
    // ---------------------------------

    /* initialize retry vars for loop below */
    // --- リトライ設定の初期化 ---
    per->retry_sleep_default = config->retry_delay_ms;
    per->retry_remaining = config->req_retry;
    per->retry_sleep = per->retry_sleep_default; /* ms */
    per->retrystart = curlx_now();
    // ----------------------------

    /* Here's looping around each globbed URL */
    // --- globインデックスの更新と完了 ---
    if(++state->urlidx >= state->urlnum) {
      state->urlidx = state->urlnum = 0;
      glob_cleanup(&state->urlglob);
      state->upidx++;
      curlx_safefree(state->uploadfile); /* clear it to get the next */
    }
    // ------------------------------------

    *added = TRUE;
    break;
  }
  return result;
}
```

#### `curl_easy_perform`

```c
// lib/easy.c

CURLcode curl_easy_perform(CURL *curl)
{
  return easy_perform(curl, FALSE);
}

static CURLcode easy_perform(struct Curl_easy *data, bool events)
{
  struct Curl_multi *multi; // 複数のeasyハンドルをまとめて並行転送するためのハンドル
  CURLMcode mresult;
  CURLcode result = CURLE_OK;
  struct Curl_sigpipe_ctx sigpipe_ctx;

  if (!data) return CURLE_BAD_FUNCTION_ARGUMENT;

  /* clear this as early as possible */
  // エラーバッファをクリア
  if (data->set.errorbuffer) data->set.errorbuffer[0] = 0;
  // OSエラー番号をリセット
  data->state.os_errno = 0;

  // すでにdata->multiに追加済みのeasyハンドルがある場合はエラー
  if (data->multi) {
    failf(data, "easy handle already used in multi handle");
    return CURLE_FAILED_INIT;
  }

  /* if the handle has a connection still attached (it is/was a connect-only
     handle) then disconnect before performing */
  // connect-onlyの接続を持つハンドルを再利用する際、残存している古い接続を切断
  if (data->conn) {
    struct connectdata *c;
    curl_socket_t s;
    Curl_detach_connection(data);

    s = Curl_getconnectinfo(data, &c);

    if ((s != CURL_SOCKET_BAD) && c) {
      Curl_conn_terminate(data, c, TRUE);
    }

    DEBUGASSERT(!data->conn);
  }

  // multiハンドルの生成
  // serial_transfers -> curl_easy_perform -> easy_performの場合は
  // adminハンドル + easyハンドルの二つを含むmultiハンドルになる
  if (data->multi_easy) {
    multi = data->multi_easy;
  } else {
    /* this multi handle will only ever have a single easy handle attached to
       it, so make it use minimal hash sizes */
    multi = Curl_multi_handle(16, 1, 3, 7, 3);
    if(!multi) return CURLE_OUT_OF_MEMORY;
  }

  // コールバック内からの再帰呼び出しをチェック
  if (multi->in_callback) return CURLE_RECURSIVE_API_CALL;

  /* Copy relevant easy options to the multi handle */
  // multiオプションのセット
  curl_multi_setopt(multi, CURLMOPT_MAXCONNECTS, (long)data->set.maxconnects);
  curl_multi_setopt(multi, CURLMOPT_QUICK_EXIT, (long)data->set.quick_exit);

  data->multi_easy = NULL; /* pretend it does not exist */
  mresult = curl_multi_add_handle(multi, data); // => curl_multi_add_handle (lib/multi.c)
  // 1. multiハンドル / easyハンドルのバリデーションチェック
  // 2. curl_multi_cleanup(data->multi_easy) 既存のmulti_easyの破棄
  // 3. multi_xfers_add(multi, data) multiハンドルにeasyハンドルを追加
  // 4. Curl_llist_init(&data->state.timeoutlist, NULL) このハンドル用のタイムアウトイベントリストを初期化
  // 5. data->set.errorbuffer[0] = 0, data->state.os_errno = 0 前回転送時のエラーバッファをクリア
  // 6. data->multi = multi easyにmultiへの逆参照をセット
  // 7. multistate(data, MSTATE_INIT) で状態をMSTATE_INITにセット
  // 9. Curl_uint32_bset_add(&multi->process, data->mid) multi->processにeasyハンドルに割り当てられたIDを追加
  // 10. Curl_cpool_xfer_init(data) 接続プールにこのハンドルが転送を開始することを通知
  // 11. Curl_multi_mark_dirty(data) (dirty フラグを立てる)
  // 12. multi->admin->set.timeout = data->set.timeout adminハンドルへのタイムアウト設定コピー
  // 13. multi_assess_wakeup(multi) wakeup監視の設定
  // 14. Curl_update_timer(multi) タイマ更新

  if (mresult) {
    curl_multi_cleanup(multi);
    if(mresult == CURLM_OUT_OF_MEMORY) return CURLE_OUT_OF_MEMORY;
    return CURLE_FAILED_INIT;
  }

  /* assign this after curl_multi_add_handle() */
  data->multi_easy = multi;

  // 書き込み先のソケットが切断された際に発生するSIGPIPEシグナルを無視する
  sigpipe_init(&sigpipe_ctx);
  sigpipe_apply(data, &sigpipe_ctx);

  /* run the transfer */
  // 転送の実行
  result = events ? easy_events(multi) : easy_transfer(multi); // => easy_transfer (lib/easy.c)

  // 後処理
  /* ignoring the return code is not nice, but atm we cannot really handle
     a failure here, room for future improvement! */
  (void)curl_multi_remove_handle(multi, data);

  sigpipe_restore(&sigpipe_ctx);

  /* The multi handle is kept alive, owned by the easy handle */
  return result;
}

static CURLcode easy_transfer(struct Curl_multi *multi)
{
  bool done = FALSE;
  CURLMcode mresult = CURLM_OK;
  CURLcode result = CURLE_OK;

  // easyハンドル1件分のレスポンスを取得するまで poll -> perform -> 完了確認 のループを繰り返す
  while (!done && !mresult) {
    int still_running = 0;

    // I/Oイベントをpoll
    mresult = curl_multi_poll(multi, NULL, 0, 1000, NULL); // => curl_multi_poll (lib/multi.c)

    // I/O可能になったソケットに実際の読み書きを行い、data->mstate (CURLMstate) を更新する
    if (!mresult) mresult = curl_multi_perform(multi, &still_running); // => curl_multi_perform (lib/multi.c) WIP

    /* only read 'still_running' if curl_multi_perform() return OK */
    if (!mresult && !still_running) {
      int rc;
      // CURLMSG_DONE (完了) メッセージの取得
      CURLMsg *msg = curl_multi_info_read(multi, &rc);

      if (msg) {
        result = msg->data.result;
        done = TRUE;
      }
    }
  }

  /* Make sure to return some kind of error if there was a multi problem */
  if (mresult) {
    result = (mresult == CURLM_OUT_OF_MEMORY) ? CURLE_OUT_OF_MEMORY :
      /* The other multi errors should never happen, so return something suitably generic */
      CURLE_BAD_FUNCTION_ARGUMENT;
  }

  return result;
}
```

#### `curl_multi_perform` WIP

```c
// lib/multi.c
CURLMcode curl_multi_perform(CURLM *m, int *running_handles)
{
  struct Curl_multi *multi = m;

  if (!GOOD_MULTI_HANDLE(multi)) return CURLM_BAD_HANDLE;

  return multi_perform(multi, running_handles);
}

static CURLMcode multi_perform(struct Curl_multi *multi, int *running_handles) // WIP
{
  CURLMcode returncode = CURLM_OK;
  struct curltime start = *multi_now(multi); // multi_performの開始時刻
  uint32_t mid;
  struct Curl_sigpipe_ctx sigpipe_ctx;

  // 転送コールバック中、あるいは通知コールバック中の再入防止
  if (multi->in_callback) return CURLM_RECURSIVE_API_CALL;
  if (multi->in_ntfy_callback) return CURLM_RECURSIVE_API_CALL;

  // ネットワーク書き込み中に相手が切断した場合でもSIGPIPEを無視する
  sigpipe_init(&sigpipe_ctx);

  // 処理すべきeasyハンドルのID セットが存在する場合
  if (Curl_uint32_bset_first(&multi->process, &mid)) {
    CURL_TRC_M(multi->admin, "multi_perform(running=%u)", Curl_multi_xfers_running(multi));

    do {
      // midから実際のCurl_easyポインタを取得
      struct Curl_easy *data = Curl_multi_get_easy(multi, mid);
      CURLMcode mresult;

      if (!data) { // Curl_easyポインタが取得できない場合
        DEBUGASSERT(0);
        Curl_uint32_bset_remove(&multi->process, mid);
        Curl_uint32_bset_remove(&multi->dirty, mid);
        continue;
      }

      // 状態を1ステップ進める
      mresult = multi_runsingle(multi, data, &sigpipe_ctx); // => multi_runsingle (lib/multi.c) WIP

      if (mresult) returncode = mresult;
    } while(Curl_uint32_bset_next(&multi->process, mid, &mid)); // セットを使い切るまでループを続ける
  }

  // SIGPIPEを無視する設定を元に戻す
  sigpipe_restore(&sigpipe_ctx);

  // ループ中にmultiの状態が変化した場合
  if (multi_ischanged(multi, TRUE)) process_pending_handles(multi);

  // libcurl 内部のイベント通知機構に通知が届いている場合
  if (!returncode && CURL_MNTFY_HAS_ENTRIES(multi)) returncode = Curl_mntfy_dispatch_all(multi);

  /*
   * Remove all expired timers from the splay since handles are dealt
   * with unconditionally by this function and curl_multi_timeout() requires
   * that already passed/handled expire times are removed from the splay.
   *
   * It is important that the 'now' value is set at the entry of this function
   * and not for the current time as it may have ticked a little while since
   * then and then we risk this loop to remove timers that actually have not
   * been handled!
   */
  // タイマーツリーが存在する場合
  if (multi->timetree) {
    struct Curl_tree *t = NULL;

    do {
      // start前に期限切れになったノードを取得
      multi->timetree = Curl_splaygetbest(&start, multi->timetree, &t);

      if (t) {
        /* the removed may have another timeout in queue */
        struct Curl_easy *data = Curl_splayget(t);
        // ハンドルに次のタイムアウトがあればツリーに再登録
        (void)add_next_timeout(&start, multi, data);

        // ハンドルがMSTATE_PENDING状態の場合
        if (data->mstate == MSTATE_PENDING) {
          bool stream_unused;
          CURLcode result_unused;

          // タイムアウトさせてMSTATE_CONNECTへ進める
          if (multi_handle_timeout(data, &stream_unused, &result_unused)) {
            infof(data, "PENDING handle timeout");
            move_pending_to_connect(multi, data);
          }
        }
      }
    } while(t);
  }

  // まだ実行中のハンドル数を返す
  if (running_handles) {
    unsigned int running = Curl_multi_xfers_running(multi);
    *running_handles = (running < INT_MAX) ? (int)running : INT_MAX;
  }

  // タイマーを更新してcurl_multi_poll が待機するべき時間を取得
  if (CURLM_OK >= returncode) returncode = Curl_update_timer(multi);

  return returncode;
}

// WIP
static CURLMcode multi_runsingle(
  struct Curl_multi *multi,
  struct Curl_easy *data,
  struct Curl_sigpipe_ctx *sigpipe_ctx
) {
  CURLMcode mresult; // multiレベルの実行結果
  CURLcode result = CURLE_OK; // easyハンドル単体の転送結果

  // ポインタが無効なeasyハンドルの場合
  if (!GOOD_EASY_HANDLE(data)) return CURLM_BAD_EASY_HANDLE;

  // multiレベルのコールバックが以前エラーを返している場合
  if (multi->dead) {
    /* a multi-level callback returned error before, meaning every individual
     transfer now has failed */
    result = CURLE_ABORTED_BY_CALLBACK;
    multi_posttransfer(data);
    multi_done(data, result, FALSE);
    multistate(data, MSTATE_COMPLETED);
  }

  /* transfer runs now, clear the dirty bit. This may be set
   * again during processing, triggering a re-run later. */
  // dirtyフラグ (再処理が必要なハンドル) をクリア。処理中に必要に応じて再セットされる
  Curl_uint32_bset_remove(&multi->dirty, data->mid);

  // multi->admin = multiハンドル自身の内部管理用に確保された特殊なeasyハンドル
  if (data == multi->admin) {
    #ifdef ENABLE_WAKEUP
    /* Consume any pending wakeup signals before processing.
     * This is necessary for event based processing. See #21547 */
    // curl_multi_wakeup() で創出されたシグナルをパイプから読み捨てる (#21547対応)
    (void)Curl_wakeup_consume(multi->wakeup_pair, TRUE);
    #endif

    #ifdef USE_RESOLV_THREADED
    // 別スレッドで完了した名前解決の結果を回収
    Curl_async_thrdd_multi_process(multi);
    #endif

    // cshutdn = connection shutdown 切断中の接続の後始末を進める
    Curl_cshutdn_perform(&multi->cshutdn, multi->admin, sigpipe_ctx);
    return CURLM_OK;
  }

  // SIGPIPEの抑制設定を適用する
  sigpipe_apply(data, sigpipe_ctx);

  // - mresult == CURLM_CALL_MULTI_PERFORM I/O待ちなしで次の状態にすぐ進める
  // - multi_ischanged(multi, FALSE) ループ中に他のハンドルの処理によってmultiの状態が変化した
  // いずれかの状態を満たすまでループ
  do {
    /* A "stream" here is a logical stream if the protocol can handle that
       (HTTP/2), or the full connection for older protocols */
    bool stream_error = FALSE; // 接続レベルのエラー (or ストリームレベルのエラーかどうか)
    mresult = CURLM_OK;

    // 前回のループでmultiの状態が変化していた場合
    if (multi_ischanged(multi, TRUE)) {
      CURL_TRC_M(data, "multi changed, check CONNECT_PEND queue");
      // PENDINGなハンドルをCONNECTへ遷移させる
      process_pending_handles(multi); /* multiplexed */
    }

    if (data->mstate > MSTATE_CONNECT && data->mstate < MSTATE_COMPLETED) {
      /* Make sure we set the connection's current owner */
      // CONNECTより後の状態において、data->connが確立されていることをチェック
      DEBUGASSERT(data->conn);

      if (!data->conn) return CURLM_INTERNAL_ERROR;
    }

    /* Wait for the connect state as only then is the start time stored, but
       we must not check already completed handles */
    // タイムアウトのチェック
    if ((data->mstate >= MSTATE_CONNECT) &&
        (data->mstate < MSTATE_COMPLETED) &&
        multi_handle_timeout(data, &stream_error, &result)) { // resultにエラーコードをセット
      /* Skip the statemachine and go directly to error handling section. */
      goto statemachine_end; // ステートマシンを終了させる
    }

    switch (data->mstate) {
    case MSTATE_INIT: // 初期状態
      /* Transitional state. init this transfer. A handle never comes back to this state. */
      mresult = multistate_init(data, &result); // => multistate_init (lib/multi.c)
      // 転送前の準備を行う
      // 結果: -> MSTATE_SETUP (CURLM_CALL_MULTI_PERFORM)
      break;

    case MSTATE_SETUP:
      /* Transitional state. Setup things for a new transfer.
         The handlecan come back to this state on a redirect. */
      mresult = multistate_setup(data); // => multistate_setup (lib/multi.c)
      // --max-time と --connect-timeout をタイマーツリーに登録
      // 結果: -> MSTATE_CONNECT (CURLM_CALL_MULTI_PERFORM)
      break;

    case MSTATE_CONNECT:
      mresult = multistate_connect(multi, data, &result); // => multistate_connect (lib/multi.c)
      // Curl_connectを呼び出す
      //   url_find_or_create_conn:
      //     - URLからホスト名・ポートを取得してstruct connectdataを作成
      //     - 接続プールから既存の接続を取得
      //       - あればconnected = TRUE
      //       - なければ接続上限チェック、struct connectdataにデータをセット
      //   Curl_conn_setup:
      //     - 使用するフィルタをconn->cfilterに登録
      // 結果:
      //   - -> MSTATE_PENDING (CURLM_OK)
      //   - -> MSTATE_PROTOCONNECT (CURLM_CALL_MULTI_PERFORM)
      //   - -> MSTATE_CONNECTING (CURLM_CALL_MULTI_PERFORM)
      break;

    case MSTATE_CONNECTING: // TCP接続完了待ち
      /* awaiting a completion of an asynch TCP connect */
      mresult = multistate_connecting(data, &stream_error, &result); // => multistate_connecting (lib/multi.c)
      // Curl_conn_connectを介してconn->cfilter[0]から順にフィルタのdo_connectを呼び、接続の進捗を確認
      // 結果:
      //   - -> MSTATE_PROTOCONNECT 接続完了 (CURLM_CALL_MULTI_PERFORM)
      //   - -> MSTATE_CONNECTING 接続中 (CURLM_OK 次回まで待機)
      //   - -> stream_error = TRUE 接続失敗 (CURLM_OK)
      break;

    // WIP
    case MSTATE_PROTOCONNECT:
      mresult = multistate_protoconnect(data, &stream_error, &result);
      break;

    case MSTATE_PROTOCONNECTING:
      /* protocol-specific connect phase */
      mresult = multistate_protoconnecting(data, &stream_error, &result);
      break;

    case MSTATE_DO:
      mresult = multistate_do(data, &stream_error, &result);
      break;

    case MSTATE_DOING:
      /* we continue DOING until the DO phase is complete */
      mresult = multistate_doing(data, &stream_error, &result);
      break;

    case MSTATE_DOING_MORE:
      /*
       * When we are connected, DOING MORE and then go DID
       */
      mresult = multistate_doing_more(data, &stream_error, &result);
      break;

    case MSTATE_DID:
      mresult = multistate_did(multi, data);
      break;

    case MSTATE_RATELIMITING: /* limit-rate exceeded in either direction */
      mresult = multistate_ratelimiting(data, &result);
      break;

    case MSTATE_PERFORMING:
      mresult = multistate_performing(data, &stream_error, &result);
      break;

    case MSTATE_DONE:
      mresult = multistate_done(data, &result);
      break;

    case MSTATE_COMPLETED:
      break;

    case MSTATE_PENDING:
    case MSTATE_MSGSENT:
      /* handles in these states should NOT be in this list */
      break;

    default:
      return CURLM_INTERNAL_ERROR;
    }

    if (data->mstate >= MSTATE_CONNECT &&
       data->mstate < MSTATE_DO &&
       mresult != CURLM_CALL_MULTI_PERFORM &&
       !multi_ischanged(multi, FALSE)) {
      /* We now handle stream timeouts if and only if this will be the last
       * loop iteration. We only check this on the last iteration to ensure
       * that if we know we have additional work to do immediately
       * (i.e. CURLM_CALL_MULTI_PERFORM == TRUE) then we should do that before
       * declaring the connection timed out as we may almost have a completed
       * connection. */
      multi_handle_timeout(data, &stream_error, &result);
    }

statemachine_end:

    // エラーがあれば接続を切り離してMSTATE_COMPLETEDに遷移させる
    result = is_finished(multi, data, stream_error, result);

    if (result) mresult = CURLM_CALL_MULTI_PERFORM;

    if (MSTATE_COMPLETED == data->mstate) {
      // CURLMSG_DONEメッセージをmultiの内部キューに積む。ハンドルを処理対象から外す
      handle_completed(multi, data, result);
      return CURLM_OK;
    }

  } while((mresult == CURLM_CALL_MULTI_PERFORM) || multi_ischanged(multi, FALSE));

  data->result = result;
  return mresult;
}
```

#### `Curl_connect`

```c
// lib/url.c

CURLcode Curl_connect(struct Curl_easy *data, bool *pconnected)
{
  CURLcode result;
  struct connectdata *conn;

  *pconnected = FALSE;

  /* Set the request to virgin state based on transfer settings */
  Curl_req_hard_reset(&data->req, data); // リクエスト状態をリセット

  /* Get or create a connection for the transfer. */
  result = url_find_or_create_conn(data);
  // - URLを解析してホスト名・ポート・プロトコルなどをstruct connectdataにセット
  // - file://の場合の処理
  // - 既存の接続があればそれを取得
  // - 接続上限のチェック
  // - struct connectdataにSSL設定をセット・data->connにセット・接続プールに登録
  conn = data->conn;

  if (result) goto out;

  DEBUGASSERT(conn);
  Curl_pgrsTime(data, TIMER_POSTQUEUE);

  if (conn->bits.reuse) { // 接続済み
    if (conn->attached_xfers > 1) *pconnected = TRUE; /* multiplexed */
  } else if (conn->scheme->flags & PROTOPT_NONETWORK) { // ネットワーク不要
    Curl_pgrsTime(data, TIMER_NAMELOOKUP);
    *pconnected = TRUE;
  } else { // 新たにDNS解決 + TCP接続の開始が必要
    // libcurlはプロトコルスタックに対応するレイヤードアーキテクチャを採用している
    // Curl_conn_setupの呼び出しによってプロトコル別にフィルタ (Curl_cftype) を追加する
    //
    //   /* A connection filter type, e.g. specific implementation. */
    //   struct Curl_cftype {
    //     const char *name;                        // 名前
    //     int flags;                               // フラグ
    //     int log_level;                           // ログレベル
    //     Curl_cft_destroy_this *destroy;          // フィルタのリソースを解放する関数
    //     Curl_cft_connect *do_connect;            // 接続を確立する関数
    //     Curl_cft_close *do_close;                // 接続をクローズする関数
    //     Curl_cft_shutdown *do_shutdown;          // 接続をシャットダウンする関数
    //     Curl_cft_adjust_pollset *adjust_pollset; // 転送のポーリングセットを調整する関数
    //     Curl_cft_data_pending *has_data_pending; // 接続に未処理データがあるか
    //     Curl_cft_send *do_send;                  // データを送信する関数
    //     Curl_cft_recv *do_recv;                  // データを受信する関数
    //     Curl_cft_cntrl *cntrl;                   // イベント/制御
    //     Curl_cft_conn_is_alive *is_alive;        // 接続が有効か
    //     Curl_cft_conn_keep_alive *keep_alive;    // 接続を維持するか
    //     Curl_cft_query *query;                   // フィルタチェーンに問い合わせる関数
    //   };

    result = Curl_conn_setup(data, conn, FIRSTSOCKET, CURL_CF_SSL_DEFAULT); // => Curl_conn_setup (lib/connect.c)

    if (!result) result = Curl_headers_init(data);
    CURL_TRC_M(data, "Curl_conn_setup() -> %d", result);
  }

out:
  if (result == CURLE_NO_CONNECTION_AVAILABLE) DEBUGASSERT(!conn);

  if (result && conn) {
    /* We are not allowed to return failure with memory left allocated in the
       connectdata struct, free those here */
    Curl_detach_connection(data);
    Curl_conn_terminate(data, conn, TRUE);
  }

  return result;
}
```

#### `Curl_conn_setup`

```c
// lib/connect.c

CURLcode Curl_conn_setup(struct Curl_easy *data, struct connectdata *conn, int sockindex, int ssl_mode)
{
  CURLcode result = CURLE_OK;

  // 最初の接続先を取得する
  // SOCKSプロキシ -> HTTPプロキシ -> Alt-Svcの誘導先ホスト/ポート -> オリジン の順で検索する
  struct Curl_peer *peer = Curl_conn_get_first_peer(conn, sockindex);
  // => Curl_conn_get_first_peer (lib/connect.c)

  // Curl_conn_get_first_peer (lib/connect.c)
  //
  //   struct Curl_peer *Curl_conn_get_first_peer(struct connectdata *conn, int sockindex)
  //   {
  //     #ifndef CURL_DISABLE_PROXY
  //     if(conn->socks_proxy.peer) return conn->socks_proxy.peer;
  //     if(conn->http_proxy.peer) return conn->http_proxy.peer;
  //     #endif
  //
  //     return (sockindex == SECONDARYSOCKET) ?
  //       (conn->via_peer2 ? conn->via_peer2 : conn->origin2) :
  //       (conn->via_peer ? conn->via_peer : conn->origin);
  //   }

  uint8_t dns_queries;

  DEBUGASSERT(data);
  DEBUGASSERT(conn->scheme);
  DEBUGASSERT(!conn->cfilter[sockindex]);

  // 接続先が特定できない場合
  if (!peer) return CURLE_FAILED_INIT;

  // HTTPSの場合
  #ifndef CURL_DISABLE_HTTP
  if (!conn->cfilter[sockindex] && conn->scheme->protocol == CURLPROTO_HTTPS) {
    DEBUGASSERT(ssl_mode != CURL_CF_SSL_DISABLE);

    // Curl_cft_http_connectを呼び出しHTTPS-CONNECT (接続時にプロトコルネゴシエーションを行う) フィルタを追加
    result = Curl_cf_https_setup(data, conn, sockindex); // => Curl_cf_https_setup (lib/cf-https-connect.c)
    // HTTPS-CONNECTフィルタはHTTP/1.1 / HTTP/2 / HTTP/3のうちどれを利用するかを決定する
    if (result) goto out;
  }
  #endif /* !CURL_DISABLE_HTTP */

  // SETUPフィルタを作成しconn->cfilter[sockindex]の先頭に登録する
  /* Still no cfilter set, apply default. */
  if (!conn->cfilter[sockindex]) {
    result = cf_setup_add(data, conn, sockindex, conn->transport_wanted, ssl_mode);
    // => cf_setup_add (lib/connect.c)
    if (result) goto out;
  }

  // DNSフィルタ (Curl_cft_dns) を作成 (クエリの内容を決定)
  dns_queries = Curl_resolv_dns_queries(data, conn->ip_version);
  // => Curl_resolv_dns_queries (lib/hostip.c)

  // HTTPS RRが有効な場合 (デフォルトON)
  #ifdef USE_HTTPSRR
  // DNSクエリにCURL_DNSQ_HTTPSフラグを追加
  if (sockindex == FIRSTSOCKET) dns_queries |= CURL_DNSQ_HTTPS;
  #endif

  // 作成したDNSフィルタ (Curl_cft_dns) をconn->cfilter[sockindex]の先頭に追加
  result = Curl_cf_dns_add(data, conn, sockindex, peer, dns_queries, conn->transport_wanted);
  // => Curl_cf_dns_add (lib/cf-dns.c)
  //    -> cf_dns_create(&cf, data, peer, dns_queries, transport, for_proxy, FALSE);
  //    -> Curl_cf_create(&cf, &Curl_cft_dns, ctx)
  //
  //   struct Curl_cftype Curl_cft_dns = {
  //     "DNS",
  //     CF_TYPE_SETUP,
  //     CURL_LOG_LVL_NONE,
  //     cf_dns_destroy,
  //     cf_dns_connect,
  //     cf_dns_close,
  //     Curl_cf_def_shutdown,
  //     cf_dns_adjust_pollset,
  //     Curl_cf_def_data_pending,
  //     Curl_cf_def_send,
  //     Curl_cf_def_recv,
  //     cf_dns_cntrl,
  //     Curl_cf_def_conn_is_alive,
  //     Curl_cf_def_conn_keep_alive,
  //     Curl_cf_def_query,
  //   };

  DEBUGASSERT(conn->cfilter[sockindex]);

out:
  return result;
}
```

### `multistate_connecting`

```c
// lib/multi.c

static CURLMcode multistate_connecting(struct Curl_easy *data, bool *stream_error, CURLcode *result)
{
  bool connected;

  // あるはずのdata->connがない場合
  if (!data->conn) {
    DEBUGASSERT(0);
    *result = CURLE_FAILED_INIT;
    return CURLM_OK;
  }

  // 受信がpause中ではない場合
  if (!Curl_xfer_recv_is_paused(data)) {
    // Curl_conn_connectを経由してフィルタチェーンのdo_connectを呼び、フィルタが担う接続処理を1ステップ進める
    *result = Curl_conn_connect(data, FIRSTSOCKET, FALSE, &connected); // => Curl_conn_connect (lib/cfilters.c)

    // 接続完了かつエラーなしの場合
    if (connected && !(*result)) {
      if (!data->conn->bits.reuse && Curl_conn_is_multiplex(data->conn, FIRSTSOCKET)) {
        /* new connection, can multiplex, wake pending handles */
        // 新規の多重化接続を確立
        // MSTATE_PENDINGで待機していた他のハンドルをMSTATE_CONNECTに遷移させる
        process_pending_handles(data->multi); // => process_pending_handles (lib/multi.c)
      }

      // MSTATE_PROTOCONNECTへ遷移
      multistate(data, MSTATE_PROTOCONNECT);
      return CURLM_CALL_MULTI_PERFORM;
    } else if (*result) {
      /* failure detected */
      CURL_TRC_M(data, "connect failed -> %d", *result);
      multi_posttransfer(data); // 転送後処理
      multi_done(data, *result, TRUE); // 接続の切り離し・リソースの解放
      *stream_error = TRUE;

      return CURLM_OK;
    }
  }

  return CURLM_OK;
}
```

#### `Curl_conn_connect`

```c
// lib/cfilters.c

CURLcode Curl_conn_connect(struct Curl_easy *data, int sockindex, bool blocking, bool *done)
{
  // ブロッキングモードでソケットのI/O完了を待つpollのための構造体
  #define CF_CONN_NUM_POLLS_ON_STACK 5
  struct pollfd a_few_on_stack[CF_CONN_NUM_POLLS_ON_STACK];
  struct easy_pollset ps;
  struct curl_pollfds cpfds;

  // 処理対象のフィルタ
  struct Curl_cfilter *cf;
  CURLcode result = CURLE_OK;

  DEBUGASSERT(data);
  DEBUGASSERT(data->conn);
  if (!CONN_SOCK_IDX_VALID(sockindex)) return CURLE_BAD_FUNCTION_ARGUMENT;

  // ネットワーク接続が不要なプロトコルは即完了扱いとする
  if (data->conn->scheme->flags & PROTOPT_NONETWORK) {
    *done = TRUE;
    return CURLE_OK;
  }

  // conn->cfilter[sockindex] の先頭フィルタを取得
  cf = data->conn->cfilter[sockindex];

  if (!cf) { // フィルタが登録されていない場合
    *done = FALSE;
    return CURLE_FAILED_INIT;
  }

  *done = (bool)cf->connected;

  if (*done) return CURLE_OK; // すでに接続済みであればreturn

  // ブロッキングモード用のpoll構造体を初期化
  Curl_pollset_init(&ps);
  Curl_pollfds_init(&cpfds, a_few_on_stack, CF_CONN_NUM_POLLS_ON_STACK);

  while (!*done) {
    if (Curl_conn_needs_flush(data, sockindex)) { // フィルタチェーンに送信待ちのバッファが残っている場合
      DEBUGF(infof(data, "Curl_conn_connect(index=%d), flush", sockindex));
      result = Curl_conn_flush(data, sockindex);

      if (result && (result != CURLE_AGAIN)) return result;
    }

    // 取得したフィルタのdo_connectを呼ぶ
    result = cf->cft->do_connect(cf, data, done);
    // Curl_cft_dnsの場合 cf_dns_connect (lib/cf-dns.c)

    CURL_TRC_CF(data, cf, "Curl_conn_connect(block=%d) -> %d, done=%d", blocking, result, *done);

    if (!result && *done) { // エラーなくフィルタのdo_connectがdone = TRUEを返した場合
      /* Now that the complete filter chain is connected, let all filters
       * persist information at the connection. E.g. cf-socket sets the
       * socket and ip related information. */
      // 接続情報を永続化させるための制御イベントをフィルタチェーン全体に送る
      cf_cntrl_update_info(data, data->conn);
      // 接続にかかった時間などの統計情報を記録
      conn_report_connect_stats(cf, data);
      // この接続が最後に使われた時刻を記録
      data->conn->keepalive = *Curl_pgrs_now(data);

      VERBOSE(result = cf_verboseconnect(data, cf));
      VERBOSE(Curl_conn_trc_filters(data, sockindex, "connected"));

      // 完了したフィルタをフィルタチェーンから取り除く
      conn_remove_setup_filters(data, sockindex);
      VERBOSE(Curl_conn_trc_filters(data, sockindex, "reduced to"));

      goto out;
    } else if (result) {
      CURL_TRC_CF(data, cf, "Curl_conn_connect(), filter returned %d", result);
      VERBOSE(Curl_conn_trc_filters(data, sockindex, "failed to connect"));
      conn_report_connect_stats(cf, data);
      goto out;
    }

    // 以降、フィルタのdo_connectがdone = FALSEを返した場合
    if (!blocking) {
      goto out;
    } else { // ブロッキングモードの場合
      /* check allowed time left */
      const timediff_t timeout_ms = Curl_timeleft_ms(data);
      curl_socket_t sockfd = Curl_conn_cf_get_socket(cf, data);
      int rc;

      if (timeout_ms < 0) { // タイムアウトの場合
        /* no need to continue if time already is up */
        failf(data, "connect timeout");
        result = CURLE_OPERATION_TIMEDOUT;
        goto out;
      }

      // このループで監視するソケットセットを構築
      CURL_TRC_CF(data, cf, "Curl_conn_connect(block=1), do poll");
      Curl_pollset_reset(&ps);
      Curl_pollfds_reset(&cpfds);

      /* In general, we want to send after connect, wait on that. */
      if (sockfd != CURL_SOCKET_BAD) result = Curl_pollset_set_out_only(data, &ps, sockfd);
      if (!result) result = Curl_conn_adjust_pollset(data, data->conn, &ps);
      if (result) goto out;

      result = Curl_pollfds_add_ps(&cpfds, &ps);
      if (result) goto out;

      // poll(2) を呼び、ソケットがI/O可能になるまで待機
      rc = Curl_poll(cpfds.pfds, cpfds.n, CURLMIN(timeout_ms, (cpfds.n ? 1000 : 10)));
      CURL_TRC_CF(data, cf, "Curl_conn_connect(block=1), Curl_poll() -> %d", rc);

      if (rc < 0) {
        result = CURLE_COULDNT_CONNECT;
        goto out;
      }
      /* continue iterating */
    }
  }

out:
  Curl_pollset_cleanup(&ps);
  Curl_pollfds_cleanup(&cpfds);
  return result;
}
```

#### `cf_dns_connect`

```c
// lib/cf-dns.c

static CURLcode cf_dns_connect(struct Curl_cfilter *cf, struct Curl_easy *data, bool *done)
{
  struct cf_dns_ctx *ctx = cf->ctx; // cf_dns_ctx = このフィルタインスタンス固有の状態

  if (cf->connected) { // すでに接続済みの場合
    *done = TRUE;
    return CURLE_OK;
  }

  *done = FALSE;

  if (!ctx->started) { // 初回呼び出しの場合
    ctx->started = TRUE;
    // DNS問い合わせを開始
    ctx->resolv_result = cf_dns_start(cf, data, &ctx->dns); // => cf_dns_start (lib/cf-dns.c)
  }

  if (!ctx->dns && !ctx->resolv_result) { // DNS解決未完了の場合
    // ワーカースレッドの結果を回収
    ctx->resolv_result = Curl_resolv_take_result(data, ctx->resolv_id, &ctx->dns);
    // => Curl_resolv_take_result (lib/hostip.c)
  }

  if (ctx->resolv_result) { // DNS解決に失敗した場合
    CURL_TRC_CF(data, cf, "error resolving: %d", ctx->resolv_result);
    return ctx->resolv_result;
  }

  if (ctx->dns && !ctx->announced) { // DNS解決が完了し、結果を取得した場合
    ctx->announced = TRUE;

    if (cf->sockindex == FIRSTSOCKET) {
      cf->conn->bits.dns_resolved = TRUE;
      Curl_pgrsTime(data, TIMER_NAMELOOKUP);
    }
    cf_dns_report(cf, data, ctx->dns);
  }

  // 下位フィルタへのdo_connect呼び出しを行わない (他の回答を待機したい) 場合
  if (!cf_dns_ready_to_connect(cf, data)) return CURLE_OK;

  // 下位フィルタのdo_connect呼び出しを行う場合
  if (cf->next && !cf->next->connected) {
    bool sub_done;
    CURLcode result = Curl_conn_cf_connect(cf->next, data, &sub_done); // => Curl_conn_cf_connect (lib/cf-dns.c)

    // Curl_conn_cf_connect (lib/cf-dns.c)
    //
    // CURLcode Curl_conn_cf_connect(struct Curl_cfilter *cf, struct Curl_easy *data, bool *done)
    // {
    //   if (cf) return cf->cft->do_connect(cf, data, done);
    //   return CURLE_FAILED_INIT;
    // }

    if (result || !sub_done) return result;
    DEBUGASSERT(sub_done);
  }

  // --- 下位フィルタの接続完了後 ---

  /* sub filter chain is connected */
  CURL_TRC_CF(data, cf, "connected filter chain below");

  if (ctx->complete_resolve && !ctx->dns && !ctx->resolv_result) {
    /* This filter only connects when it has resolved everything. */
    CURL_TRC_CF(data, cf, "delay connect until resolve complete");
    return CURLE_OK;
  }

  *done = TRUE;
  cf->connected = TRUE;
  Curl_resolv_destroy(data, ctx->resolv_id); // DNS解決用のリソースを解放
  return CURLE_OK;
}
```

### `cf_dns_start`

```c
// lib/cf-dns.c

static CURLcode cf_dns_start(struct Curl_cfilter *cf, struct Curl_easy *data, struct Curl_dns_entry **pdns)
{
  struct cf_dns_ctx *ctx = cf->ctx;
  timediff_t timeout_ms = Curl_timeleft_ms(data); // タイムアウトmsの取得
  CURLcode result;

  *pdns = NULL;

  CURL_TRC_CF(data, cf, "cf_dns_start %s %s:%u",
              ctx->peer->unix_socket ? "unix-domain-socket" : "host",
              ctx->peer->hostname, ctx->peer->port);

  if (ctx->peer->unix_socket) { // Unixドメインソケット
    ctx->dns_queries = 0;
  } else if (Curl_is_ipv4addr(ctx->peer->hostname)) { // ホスト名がIPv4 アドレスリテラルの場合
    // Aレコードのクエリフラグを立てる (実際にはDNS問い合わせしない)
    ctx->dns_queries |= CURL_DNSQ_A;
  } else if(ctx->peer->ipv6) { // #ifdef USE_IPV6 ホスト名がIPv6アドレスリテラルの場合
    // AAAAレコードのクエリフラグを立てる (実際にはDNS問い合わせしない)
    ctx->dns_queries |= CURL_DNSQ_AAAA;
  }

  result = Curl_resolv( // => Curl_resolv (lib/hostip.c) 名前解決のエントリポイント
    data, ctx->peer, ctx->dns_queries, ctx->transport, (bool)ctx->for_proxy, timeout_ms, &ctx->resolv_id, pdns
  );

  DEBUGASSERT(!result || !*pdns);

  if (!result) { /* resolved right away, either sync or from dnscache */
    // DNSキャッシュヒットまたはIPアドレスリテラルの場合は即座に返る
    DEBUGASSERT(*pdns);
    return CURLE_OK;
  }  else if (result == CURLE_AGAIN) { /* async resolv in progress */
    // 非同期クエリがスレッドキューに投入され、処理が継続中
    // 次回のcf_dns_connectでCurl_resolv_take_resultを呼んで結果を回収する
    return CURLE_OK;
  } else if (result == CURLE_OPERATION_TIMEDOUT) { /* took too long */
    // 解決開始前にすでにタイムアウトしていた
    failf(data, "Failed to resolve '%s' with timeout after %"
          FMT_TIMEDIFF_T " ms", ctx->peer->hostname,
          curlx_ptimediff_ms(Curl_pgrs_now(data),
                             &data->progress.t_startsingle));
    return CURLE_OPERATION_TIMEDOUT;
  } else {
    // その他のエラー
    DEBUGASSERT(result);
    failf(data, "Could not resolve: %s", ctx->peer->hostname);
    return result;
  }
}
```

#### `Curl_resolv`

```c
// lib/hostip.c

CURLcode Curl_resolv(
  struct Curl_easy *data,
  struct Curl_peer *peer,
  uint8_t dns_queries,
  uint8_t transport,
  bool for_proxy,
  timediff_t timeout_ms,
  uint32_t *presolv_id,
  struct Curl_dns_entry **pdns
) {
  *presolv_id = 0; // 非同期クエリの識別子
  *pdns = NULL; // 解決結果の出力先

  if (timeout_ms < 0) { // タイムアウト済みの場合
    /* got an already expired timeout */
    return CURLE_OPERATION_TIMEDOUT;
  } else if (!timeout_ms) { // タイムアウト未設定の場合
    timeout_ms = CURL_TIMEOUT_RESOLVE_MS; // (内部デフォルト値)
  }

  #ifdef USE_UNIX_SOCKETS
  // --unix-socket オプションが指定されている場合、DNS解決は不要
  if(peer->unix_socket) return resolv_unix(data, peer->hostname, (bool)peer->abstract_uds, pdns);
  #else
  // USE_UNIX_SOCKETSが無効なビルドでUnixドメインソケットを使おうとした場合はエラーを返す
  if(peer->unix_socket) return hostip_resolv_failed(data, peer->hostname, for_proxy);
  #endif

  #ifdef USE_ALARM_TIMEOUT // SIGALRM を使ったタイムアウト機能が有効なビルド (主に古いPOSIX環境)
  if (timeout_ms && data->set.no_signal) {
    /* Cannot use ALARM when signals are disabled */
    // --no-signalが設定されている場合、シグナルを使えないのでSIGALRMによるタイムアウトができない
    timeout_ms = 0;
  }

  if (timeout_ms && !Curl_doh_wanted(data)) {
    // タイムアウトが有効かつDoHを使わない場合、SIGALRMタイムアウト付きの同期DNS解決を行う
    return resolv_alarm_timeout(
      data, dns_queries, peer->hostname, peer->port, transport, for_proxy, timeout_ms, presolv_id, pdns
    );
  }
  #endif /* !USE_ALARM_TIMEOUT */

  #ifndef CURLRES_ASYNCH // ブロッキングgetaddrinfo()を使う場合
  if (timeout_ms) infof(data, "timeout on name lookup is not supported");
  #endif

  return hostip_resolv( // => hostip_resolv (lib/hostip.c) 名前解決の実行
    data, dns_queries, peer->hostname, peer->port, transport, for_proxy, timeout_ms, TRUE, presolv_id, pdns
  );
}
```

#### `hostip_resolv`

```c
// lib/hostip.c

static CURLcode hostip_resolv(
  struct Curl_easy *data,
  uint8_t dns_queries,
  const char *hostname,
  uint16_t port,
  uint8_t transport,
  bool for_proxy,
  timediff_t timeout_ms,
  bool allowDOH,
  uint32_t *presolv_id,
  struct Curl_dns_entry **pdns
) {
  size_t hostname_len;
  CURLcode result = RESOLV_FAIL(for_proxy); // プロキシかどうかによって返すエラーコードを切り替える
  bool cache_dns = FALSE; // 解決結果をDNSキャッシュに追加するかどうか

  (void)timeout_ms; /* not used in all ifdefs */
  *presolv_id = 0;
  *pdns = NULL;

  #ifdef CURL_DISABLE_DOH // DoHが無効なビルド
  (void)allowDOH;
  #endif

  /* We should intentionally error and not resolve .onion TLDs */
  hostname_len = strlen(hostname); // ホスト名の長さを取得
  DEBUGASSERT(hostname_len);

  if (hostname_len >= 7 &&
     (curl_strequal(&hostname[hostname_len - 6], ".onion") || // onion = Torネットワーク専用の疑似TLD
      curl_strequal(&hostname[hostname_len - 7], ".onion."))) {
    failf(data, "Not resolving .onion address (RFC 7686)");
    goto out;
  }

  #ifdef DEBUGBUILD
  CURL_TRC_DNS(data, "hostip_resolv(%s:%u, queries=%s)", hostname, port, Curl_resolv_query_str(dns_queries));
  if ((CURL_DNSQ_IP(dns_queries) == CURL_DNSQ_AAAA) && getenv("CURL_DBG_RESOLV_FAIL_IPV6")) {
    infof(data, "DEBUG fail ipv6 resolve");
    result = hostip_resolv_failed(data, hostname, for_proxy);
    goto out;
  }
  #endif

  /* Let's check our DNS cache first */
  // DNSキャッシュ multi->dnscacheまたはshare->dnscache を検索
  result = Curl_dnscache_get(data, dns_queries, hostname, port, pdns);

  if (*pdns) { // キャッシュヒットした場合は*pdnsに結果をセット
    infof(data, "Hostname %s was found in DNS cache", hostname);
    result = CURLE_OK;
  } else if(result) { // ネガティブキャッシュヒットした場合は即エラー
    infof(data, "Negative DNS entry");
    result = hostip_resolv_failed(data, hostname, for_proxy);
  } else {
    /* No luck, we need to start resolving. */
    // 実際のDNS問い合わせを開始する
    cache_dns = TRUE;
    result = hostip_resolv_start( // => hostip_resolv_start (lib/hostip.c)
      data, dns_queries, hostname, port, transport, for_proxy, timeout_ms, allowDOH,presolv_id, pdns
    );
  }

out:
  if (result && (result != CURLE_AGAIN)) {
    Curl_dns_entry_unlink(data, pdns);

    if (IS_RESOLV_FAIL(result)) {
      if (cache_dns) Curl_dnscache_add_negative(data, dns_queries, hostname, port);
      failf(data, "Could not resolve: %s:%u", hostname, port);
    } else {
      failf(data, "Error %d resolving %s:%u", result, hostname, port);
    }
  } else if(cache_dns && *pdns) {
    result = Curl_dnscache_add(data, *pdns);
    if (result) Curl_dns_entry_unlink(data, pdns);
  }

  return result;
}
```

#### `hostip_resolv_start`

```c
// lib/hostip.c

static CURLcode hostip_resolv_start(
  struct Curl_easy *data,
  uint8_t dns_queries,
  const char *hostname,
  uint16_t port,
  uint8_t transport,
  bool for_proxy,
  timediff_t timeout_ms,
  bool allowDOH,
  uint32_t *presolv_id,
  struct Curl_dns_entry **pdns
) {
  #ifdef USE_CURL_ASYNC // 非同期DNSが有効な場合
  struct Curl_resolv_async *async = NULL;
  #endif

  struct Curl_addrinfo *addr = NULL; // 同期解決の場合にgetaddrinfoの結果を受け取るポインタ
  size_t hostname_len;
  CURLcode result = CURLE_OK;

  (void)timeout_ms; /* not in all ifdefs */
  *presolv_id = 0;
  *pdns = NULL;

  hostname_len = strlen(hostname);

  // hostnameを"localhost"として判定した場合
  if(curl_strequal(hostname, "localhost") ||
     curl_strequal(hostname, "localhost.") ||
     tailmatch(hostname, hostname_len, STRCONST(".localhost")) ||
     tailmatch(hostname, hostname_len, STRCONST(".localhost."))) {
    // DNS問い合わせは開始せず、解決開始のタイムスタンプ記録などの通知処理だけ行う
    result = Curl_resolv_announce_start(data, NULL);
    if (result) goto out;
    // "localhost"からIPアドレスを示すstruct Curl_addrinfoを取得する
    addr = get_localhost(port, hostname);
    if (!addr) result = CURLE_OUT_OF_MEMORY;
    goto out;
  }

  #ifndef CURL_DISABLE_DOH // DOHが有効なビルド
  if (!Curl_is_ipaddr(hostname) && // IPアドレスリテラルでない
     allowDOH && // かつ、DoHが許可されている
     data->set.doh) { // かつ、--doh-urlでDoHサーバを指定されている
    // 解決開始のタイムスタンプ記録などの通知処理
    result = Curl_resolv_announce_start(data, NULL);
    if (result) goto out;

    if (!async) {
      // ホスト名・ポート・クエリ種別、結果などの情報などを保持するstruct Curl_resolv_asyncを生成する
      async = hostip_async_new(data, dns_queries, hostname, port, transport, for_proxy, timeout_ms);

      if (!async) {
        result = CURLE_OUT_OF_MEMORY;
        goto out;
      }
    }
    result = Curl_doh(data, async); // => Curl_doh (lib/doh.c)
    goto out;
  }
  #else
  (void)allowDOH;
  #endif

  /* Can we provide the requested IP specifics in resolving? */
  // クエリとシステム要件が一致しているかどうか
  if (!can_resolve_dns_queries(data, dns_queries)) { // => can_resolve_dns_queries (lib/hostip.c )

    // can_resolve_dns_queries (lib/hostip.c )
    //
    //   static bool can_resolve_dns_queries(struct Curl_easy *data, uint8_t dns_queries)
    //   {
    //     (void)data;
    //     // AAAAクエリを要求しているのにシステムがIPv6に対応していない
    //     if ((CURL_DNSQ_IP(dns_queries) == CURL_DNSQ_AAAA) && !ipv6works(data)) return FALSE;
    //     return TRUE;
    //   }

    result = RESOLV_FAIL(for_proxy);
    goto out;
  }

  #ifdef CURLRES_ASYNCH
  (void)addr;

  if (!async) {
    async = hostip_async_new(data, dns_queries, hostname, port, transport, for_proxy, timeout_ms);

    if (!async) {
      result = CURLE_OUT_OF_MEMORY;
      goto out;
    }
  }

  // スレッドキュー (USE_RESOLV_THREADED) またはc-ares (USE_RESOLV_ARES) にDNSクエリを投入
  result = Curl_async_getaddrinfo(data, async); // => Curl_async_getaddrinfo (lib/hostip.c)

  // 直後に結果が返ってきていないかを確認
  if (result == CURLE_AGAIN) {
    /* the answer might be there already. Check. */
    CURLcode r2 = hostip_resolv_take_result(data, async, pdns);
    // => hostip_resolv_take_result (lib/asyn-ares.c もしくは lib/asyn-thrdd.c)

    if (r2) {
      result = r2;
    } else if(*pdns) {
      result = CURLE_OK; // 結果を取得
    }
  }
  #else
  // 同期DNSの場合
  result = Curl_resolv_announce_start(data, NULL);
  if (result) goto out;
  // getaddrinfoの呼び出し (完了するまでブロック)
  addr = Curl_sync_getaddrinfo(data, dns_queries, hostname, port, transport);
  if (!addr) result = RESOLV_FAIL(for_proxy);
  #endif

out:
  if (!result) {
    if (addr) { // 同期解決が完了
      /* we got a response, create a dns entry, add to cache, return */
      DEBUGASSERT(!*pdns);
      // DNSエントリを作成し*pdnsにセット
      *pdns = Curl_dnscache_mk_entry(data, dns_queries, &addr, hostname, port);
      if (!*pdns) result = CURLE_OUT_OF_MEMORY;
    } else if (!*pdns) { // 非同期クエリが継続中
      result = CURLE_AGAIN;
    }
  } else if (*pdns) { // 非同期クエリが即完了 / DoH完了
    Curl_dns_entry_unlink(data, pdns);
  } else if (addr) { // エラー
    Curl_freeaddrinfo(addr);
  }

  #ifdef USE_CURL_ASYNC
  //  非同期クエリが継続中の場合
  if (async) {
    if (result == CURLE_AGAIN) { /* still need it, link, return id. */
      *presolv_id = async->id;
      async->next = data->state.async;
      data->state.async = async;
    } else {
      Curl_async_destroy(data, async);
    }
  }
  #endif
  return result;
}
```

### `Curl_async_getaddrinfo`

```c
// lib/asyn-ares.c
// (lib/asyn-thrdd.cにも定義されている)

CURLcode Curl_async_getaddrinfo(struct Curl_easy *data, struct Curl_resolv_async *async)
{
  struct async_ares_ctx *ares = &async->ares; // c-aresのチャンネル (ares->channel) などを保持するコンテキスト
  char service[12];
  int socktype;
  CURLcode result = CURLE_OK;

  if (ares->channel) { // ares->channelがなぜかすでに初期化されている場合
    DEBUGASSERT(0);
    result = CURLE_FAILED_INIT;
    goto out;
  }

  // c-ares チャンネルを初期化
  // -> ares_init_options (DNSスタブクライアント・タイムアウト・リトライ回数などを設定し、ares->channelに格納)
  result = async_ares_init(data, async); // => async_ares_init (lib/asyn-ares.c)

  if (result) goto out;

  // CURLOPT_RESOLVER_START_FUNCTIONコールバックが設定されている場合、呼び出す
  result = Curl_resolv_announce_start(data, ares->channel);
  // => Curl_resolv_announce_start (lib/hostip.c)
  if (result) goto out;

  // ポート番号を文字列化
  curl_msnprintf(service, sizeof(service), "%d", async->port);
  // 使用するトランスポートに応じてソケット種別を決定
  socktype = (Curl_conn_get_transport(data, data->conn) == TRNSPRT_TCP) ?
  SOCK_STREAM : // TCP (HTTP/1.1, HTTP/2)
  SOCK_DGRAM;   // UDP (HTTP/3)

  #ifdef CURLRES_IPV6 // IPv6サポートが有効なビルドの場合
  if(async->dns_queries & CURL_DNSQ_AAAA) { // AAAAクエリフラグが立っている場合
    struct ares_addrinfo_hints hints;

    memset(&hints, 0, sizeof(hints));
    CURL_TRC_DNS(data, "ares: query AAAA records for %s", async->hostname);
    hints.ai_family = PF_INET6;
    hints.ai_socktype = socktype;
    hints.ai_flags = ARES_AI_NUMERICSERV; // ポート番号を文字列として解釈する
    async->queries_ongoing++; // "進行中のクエリのカウントに1件追加"

    // c-aresにAAAAクエリを投入 (ノンブロッキング)
    ares_getaddrinfo(ares->channel, async->hostname, service, &hints, async_ares_AAAA_cb, async);
    // async_ares_AAAA_cb = 結果を取得した際に実行するコールバック
    // 結果をasyncに格納し、Curl_multi_mark_dirtyで該当ハンドルをdirtyセットに追加して
    // 次のmulti_performで処理が進むようにする
  }
  #endif /* CURLRES_IPV6 */

  if (async->dns_queries & CURL_DNSQ_A) { // Aクエリフラグが立っている場合
    struct ares_addrinfo_hints hints;

    memset(&hints, 0, sizeof(hints));
    CURL_TRC_DNS(data, "ares: query A records for %s", async->hostname);
    hints.ai_family = PF_INET;
    hints.ai_socktype = socktype;
    hints.ai_flags = ARES_AI_NUMERICSERV; // ポート番号を文字列として解釈する
    async->queries_ongoing++; // "進行中のクエリのカウントに1件追加"

    // c-aresにAクエリを投入 (ノンブロッキング)
    ares_getaddrinfo(ares->channel, async->hostname,  service, &hints, async_ares_A_cb, async);
    // async_ares_A_cb = 結果を取得した際に実行するコールバック
    // 結果をasyncに格納し、Curl_multi_mark_dirtyで該当ハンドルをdirtyセットに追加して
    // 次のmulti_performで処理が進むようにする
  }

  #ifdef USE_HTTPSRR // HTTPS RRが有効なビルドの場合
  // HTTPS RRの結果を格納するhinfoを初期化
  memset(&ares->hinfo, 0, sizeof(ares->hinfo));

  if (async->dns_queries & CURL_DNSQ_HTTPS) { // HTTPS RRクエリフラグが立っている場合
    char *rrname = NULL;

    if (async->port != 443) { // ポートが443以外の場合
      // HTTPS RRのクエリ名を _#{port}._https.#{hostname} の形式で生成 (RFC 9460)
      rrname = curl_maprintf("_%d._https.%s", async->port, async->hostname);
      if (!rrname) return CURLE_OUT_OF_MEMORY;
    }

    CURL_TRC_DNS(data, "ares: query HTTPS records for %s", rrname ? rrname : async->hostname);

    ares->hinfo.rrname = rrname;
    async->queries_ongoing++; // "進行中のクエリのカウントに1件追加"

    // c-aresにHTTPS RRクエリを投入 (ノンブロッキング)
    ares_query_dnsrec(
      ares->channel,
      rrname ? rrname : async->hostname,
      ARES_CLASS_IN,
      ARES_REC_TYPE_HTTPS,
      async_ares_rr_done,
      async,
      NULL
    );
  }
  #endif /* USE_HTTPSRR */

out:
  ares->result = result;
  return result ? result : (async->queries_ongoing ? CURLE_AGAIN : CURLE_OK);
}
```

### `Curl_doh`

```c
// lib/doh.c

CURLcode Curl_doh(struct Curl_easy *data, struct Curl_resolv_async *async)
{
  CURLcode result = CURLE_OK;

  // 1つのホスト名に対する全DoHクエリ (A / AAAA / HTTPS RR) を管理する構造体
  struct doh_probes *dohp = NULL;

  size_t i;

  DEBUGASSERT(!async->doh);
  DEBUGASSERT(async->hostname[0]);

  if (async->doh) { // async->dohがなぜかすでに初期化されている場合
    DEBUGASSERT(0); /* should not happen */
    Curl_doh_cleanup(data, async);
  }

  /* start clean, consider allocating this struct on demand */
  async->doh = dohp = curlx_calloc(1, sizeof(struct doh_probes));
  if (!dohp) return CURLE_OUT_OF_MEMORY;

  // DOH_SLOT_COUNT = ビルドの設定によって異なる。最大3 (A + AAAA + HTTPS RR)
  for(i = 0; i < DOH_SLOT_COUNT; ++i) {
    // 各スロットのprobe_mid = easyハンドルのIDとレスポンスボディを受け取るdynbufを初期化
    dohp->probe_resp[i].probe_mid = UINT32_MAX;
    curlx_dyn_init(&dohp->probe_resp[i].body, DYN_DOH_RESPONSE);
  }

  // 解決対象のホスト名とポート番号をdoh_probesにセット
  dohp->host = async->hostname;
  dohp->port = async->port;

  /* We are making sub easy handles and want to be called back when one is done. */
  // DoHリクエスト用のeasyハンドルが完了したときに呼ばれるコールバックを設定
  data->sub_xfer_done = doh_probe_done;

  /* create IPv4 DoH request */
  // AレコードのDoHクエリを発行
  if (async->dns_queries & CURL_DNSQ_A) {
    result = doh_probe_run( // => doh_probe_run (lib/doh.c)
      data,
      CURL_DNS_TYPE_A,
      async->hostname,
      data->set.str[STRING_DOH],
      data->multi,
      async->id,
      &dohp->probe_resp[DOH_SLOT_IPV4].probe_mid
    );

    if (result) goto error;
    dohp->pending++;
  }

  #ifdef USE_IPV6 // IPv6サポートが有効なビルドの場合
  if (async->dns_queries & CURL_DNSQ_AAAA) {
    /* create IPv6 DoH request */
    // AAAAレコードのDoHクエリを発行
    result = doh_probe_run( // => doh_probe_run (lib/doh.c)
      data,
      CURL_DNS_TYPE_AAAA,
      async->hostname,
      data->set.str[STRING_DOH],
      data->multi,
      async->id,
      &dohp->probe_resp[DOH_SLOT_IPV6].probe_mid
    );

    if (result) goto error;
    dohp->pending++;
  }
  #endif

  #ifdef USE_HTTPSRR // HTTPS RRサポートが有効なビルドの場合
  if (async->dns_queries & CURL_DNSQ_HTTPS) {
    char *qname = NULL;

    if (async->port != PORT_HTTPS) { // ポートが443以外の場合
      // HTTPS RRのクエリ名を _#{port}._https.#{hostname} の形式で生成 (RFC 9460)
      qname = curl_maprintf("_%d._https.%s", async->port, async->hostname);
      if (!qname) goto error;
    }

    // HTTPS RRのDoHクエリを発行
    result = doh_probe_run(
      data,
      CURL_DNS_TYPE_HTTPS,
      qname ? qname : async->hostname,
      data->set.str[STRING_DOH],
      data->multi,
      async->id,
      &dohp->probe_resp[DOH_SLOT_HTTPS_RR].probe_mid
    );

    curlx_free(qname);
    if (result) goto error;
    dohp->pending++;
  }
  #endif

  return CURLE_OK;

error:
  Curl_doh_cleanup(data, async);
  return result;
}
```

#### `Curl_resolv_take_result`

```c
// lib/hostip.c
// WIP

CURLcode Curl_resolv_take_result(struct Curl_easy *data, uint32_t resolv_id,
                                 struct Curl_dns_entry **pdns)
{
  struct Curl_resolv_async *async = Curl_async_get(data, resolv_id);
  CURLcode result;

  /* If async resolving is ongoing, this must be set */
  if(!async)
    return CURLE_FAILED_INIT;

  /* check if we have the name resolved by now (from someone else) */
  result = Curl_dnscache_get(data, async->dns_queries,
                             async->hostname, async->port, pdns);
  if(*pdns) {
    /* Tell a possibly async resolver we no longer need the results. */
    infof(data, "Hostname '%s' was found in DNS cache", async->hostname);
    Curl_async_shutdown(data, async);
    return CURLE_OK;
  }
  else if(result) {
    Curl_async_shutdown(data, async);
    return Curl_async_failed(data, async, NULL);
  }

  result = hostip_resolv_take_result(data, async, pdns); // => hostip_resolv_take_result (lib/hostip.c)

  if(*pdns) {
    /* Add to cache */
    result = Curl_dnscache_add(data, *pdns);
    if(result)
      Curl_dns_entry_unlink(data, pdns);
  }
  else if(IS_RESOLV_FAIL(result)) {
    Curl_dnscache_add_negative(data, async->dns_queries,
                               async->hostname, async->port);
    failf(data, "Could not resolve: %s:%u", async->hostname, async->port);
  }
  else if(result) {
    failf(data, "Error %d resolving %s:%u",
          result, async->hostname, async->port);
  }
  return result;
}
```
