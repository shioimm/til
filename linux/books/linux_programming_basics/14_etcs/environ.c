// 引用: ふつうのLinuxプログラミング
// 第14章 プロセスの環境 2

// environ - 環境変数の情報を持つグローバル変数
//
// #include <stdio.h>
// #include <stdlib.h>
//
// extern char **environ; 複数ファイルにまたがってenviron変数を共有する
//
// int main()
// {
//   char **p;
//
//   for (p = environ; *p; p++) {
//     printf("%s\n", *p);
//   }
//
//   exit(0);
// }
//
// #include <stdlib.h>
// char *getenv(const char *name);
//   環境変数nameの値を取得する
//
// #include <stdlib.h>
// char *putenv(char *string);
//   環境変数を"名前=値"の形でセットする
