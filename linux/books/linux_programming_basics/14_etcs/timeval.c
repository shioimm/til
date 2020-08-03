// 引用: ふつうのLinuxプログラミング
// 第14章 プロセスの環境 6

// UNIXエポック        - 1970-01-01 00:00(UTC)
// ISO8601フォーマット - YYYY-MM-DDTHH:mm:ss+UTCからの時差

// #include <time.h>
// time_t time(time_t *tptr;
//   UNIXエポックから現在までの経過秒を返す
//
// #include <sys/time.h>
// int gettimeofday(struct timeval *tv, struct timezone *tz);
//   UNIXエポックから現在までの経過秒をtvに書き込む
//   tzは常にNULL
//
// struct timeval {
//   time_t tv_sec;       秒
//   suseconds_t tv_usec; マイクロ秒
// }
//
// #include <time.h>
// struct tm *localtime(const time_t *timep);
//   time_tを年月日の表現に変換(ローカルのタイムゾーンを使用)
//
// struct tm *gmtime(const time_t *timep);
//   time_tを年月日の表現に変換(UTCを使用)
//
// time_t mktime(struct tm *tm);
//   struct tmをtime_tに変換
//
// char *asctime(const struct tm *tm);
//   tmを文字列"%a %b %d %H:%M:%S %Y"形式に変換
// char *ctime(const time_t *timep);
//   timepを文字列"%a %b %d %H:%M:%S %Y"形式に変換
//
// size_t strftime(char *buf, size_t bufsize, const char *fmt, const struct tm *tm);
//   tmをfmtに従ってフォーマットし、最大bufsize分をbufに書き込む
