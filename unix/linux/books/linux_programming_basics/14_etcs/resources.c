// 引用: ふつうのLinuxプログラミング
// 第14章 プロセスの環境 5

// リソース - CPU、メモリ、バスetc

// #include <sys/time.h>
// #include <sys/resource.h>
// int getrusage(int who, struct rusage *usage);
//   プロセスのリソース使用量をusageに書き込む
//   who - RUSAGE_SELF     自プロセス
//         RUSAGE_CHILDLEN wait()した子プロセス
//
// struct rusage {
//   struct timeval ru_utime; 使用されたユーザー時間
//   struct timeval ru_stime; 使用されたシステム時間
//   long ru_maxrss;          最大RSSサイズ
//   long ru_majflt;          メジャーフォールトの回数
//   long ru_minflt;          マイナーフォールトの回数
//   long ru_inblock;         ブロック入力オペレーションの回数
//   long ru_oublock;         ブロック出力オペレーションの回数
//   ...
// }
//
//   ユーザー時間       - プロセスが自分で消費した時間(システム時間以外)
//   システム時間       - そのプロセスのためのカーネルが働いた時間
//   メジャーフォールト - 物理ページの割り当てが起こった回数(ストレージとの入出力を伴う)
//   マイナーフォールト - 物理ページの割り当てが起こった回数(ストレージとの入出力を伴わない)
//   ブロック入力       - ブロックデバイスに対する入力
//   ブロック出力       - ブロックデバイスに対する出力
