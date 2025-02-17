// 引用: ふつうのLinuxプログラミング
// 第14章 プロセスの環境 1

// #include <unistd.h>
// char *getcwd(char *buf, size_t bufsize);
//   自プロセスのカレントワーキングディレクトリを最大bufsize分bufに書き込む
//
// #include <stdlib.h>
// #include <unistd.h>
// #include <errno.h>
//
// #define INIT_BUFISIZE 1024
//
// char *my_getcwd(void)
// {
//   char *buf, *temp;
//   size_t size = INIT_BUFISIZE;
//
//   buf = malloc(size);
//
//   if (!buf) return NULL;
//
//   for (;;) {
//     errno = 0;
//
//     if (getcwd(buf, size))  return buf;
//     if (errno != ERANGE)  break;
//
//     size *= 2;
//     tmp = realloc(buf, size);
//
//     if (!tmp) {
//       break;
//     }
//     buf = tmp;
//   }
//
//   free(buf);
//   return NULL;
// }
//
// #include <unistd.h>
// int chdir(const char *path);
//   自プロセスのカレントワーキングディレクトリをpathに変更する
