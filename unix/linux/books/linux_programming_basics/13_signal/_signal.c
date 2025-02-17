// 引用: ふつうのLinuxプログラミング
// 第13章 シグナルに関わるAPI 1

// シグナルが配送されたプロセスが起こす挙動
//   1. 無視する
//   2. 終了する
//   3. コアダンプを作成して異常終了する
//      コアダンプ - プロセスのメモリのスナップショット(core)
//
// 捕捉可能なシグナル(SIGKILL以外)は挙動を変更することができる

// signal(2)は実装上の問題があるため使用しない
//   シグナル捕捉時、OSによってハンドラの設定が解除される可能性がある
//   シグナル捕捉時、OSによってシステムコールの挙動が異なる
//   シグナル捕捉時、関数が重複して呼ばれる可能性がある
//   シグナル捕捉時、シグナルハンドラが重複して呼ばれる可能性がある

// signal(2)の代わりにsigaction(2)を使用する
//   シグナル捕捉時、OSにかかわらずシグナルハンドラの設定を保持し続ける
//   シグナル捕捉時、デフォルトでシステムコールを再起動しない
//                   (デフォルトでシステムコールを再起動するように変更可能)
//   シグナル捕捉時、指定したシグナルをブロックすることができる
//
//  #include <signal.h>
//
//  int sigaction(int sig, const struct sigaction *act, struct sigaction *oldact);
//
//  struct sigaction {
//    void(*sa_handler)(int);
//    void(*sa_sigaction)(int, siginfo_t*, void*);
//    sigset_t sa_mask;
//    int sa_flags;
//  }
//    - void(*sa_handler)(int);
//        シグナルハンドラの関数ポインタを指定
//    - void(*sa_sigaction)(int, siginfo_t*, void*);
//        シグナルハンドラの関数ポインタを指定
//        シグナル捕捉時にシグナル番号以外の詳細な情報も取得できる
//        sa_handlerと同時に使用できない
//    - sigset_t sa_mask
//        ブロック対象のシグナルを指定
//        処理中のシグナルは自動的にブロックされるため空にセットしておく
//    - int sa_flags
//        システムコールの再起動設定
//        SA_RESTARTで再起動をデフォルトにする
//
//  typedef void(*sighandler_t)(int);
//  sighandler_t trap_signal(int sig, sighandler_t handler)
//  {
//    struct sigaction act, old;
//
//    act.sa_handler = handler;
//    sigemptyset(&act.sa_mask);  act.sa_maskを空にする
//    act.sa_flags = SA_RESTART;
//
//    if (sigaction(sig, &act, &old) < 0) {
//      return NULL;
//    }
//
//    return old.sa_handler;
//  }

// Ctrl+C押下時にプロセスが終了するまで
//   0. a.シェルがパイプを構成するプロセスをfork()
//      b. シェルが端末に対してパイプのプロセスグループIDを通知(tcsetpgrp())
//      c. forkされたプロセスがそれぞれのコマンドをexec
//   1. Ctrl+C押下
//   2. カーネルの端末ドライバが1をSIGINTへ変換
//      動作中のプロセスグループへ送信
//   3. プロセスグループがデフォルトの動作に従って終了
