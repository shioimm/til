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

  struct per_transfer *per; // URL1件分の転送の実行時状態を保持する構造体
  // => struct per_transfer (src/tool_operate.h))

  /* Time to actually do the transfers */
  // 転送の実行
  if (!result) {
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
  CURLcode returncode = CURLE_OK;
  CURLcode result = CURLE_OK;
  struct per_transfer *per;
  bool added = FALSE;
  bool skipped = FALSE;

  result = create_transfer(share, &added, &skipped);
  if(result)
    return result;
  if(!added) {
    errorf("no transfer performed");
    return CURLE_READ_ERROR;
  }
  for(per = transfers; per;) {
    bool retry;
    uint32_t delay_ms;
    bool bailout = FALSE;
    struct curltime start;

    start = curlx_now();
    if(!per->skip) {
      result = pre_transfer(per);
      if(result)
        break;

      if(global->libcurl) {
        result = easysrc_perform();
        if(result)
          break;
      }

#ifdef DEBUGBUILD
      if(getenv("CURL_FORBID_REUSE"))
        (void)curl_easy_setopt(per->curl, CURLOPT_FORBID_REUSE, 1L);

      if(global->test_duphandle) {
        CURL *dup = curl_easy_duphandle(per->curl);
        curl_easy_cleanup(per->curl);
        per->curl = dup;
        if(!dup) {
          result = CURLE_OUT_OF_MEMORY;
          break;
        }
        /* a duplicate needs the share re-added */
        (void)curl_easy_setopt(per->curl, CURLOPT_SHARE, share);
      }
      if(global->test_event_based)
        result = curl_easy_perform_ev(per->curl);
      else
#endif
        result = curl_easy_perform(per->curl);
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
