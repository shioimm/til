// 引用: ふつうのLinuxプログラミング
// 第14章 プロセスの環境 4

// #include <pwd.h>
// #include <sys/types.h>
//
// struct passwd *getpwuid(uid_t id);
// struct passwd *getpwnam(const char name);
//
// struct passwd {
//   char *pw_name;   ユーザー名
//   char *pw_passwd; パスワード
//   uid_t pw_uid;    ユーザーID
//   gid_t pw_git;    グループID
//   char *pw_gecos;  本名
//   char *pw_dir;    ホームディレクトリ
//   char *pw_shell;  シェル
// }

// #include <pwd.h>
// #include <sys/types.h>
//
// struct group *getgrgid(gid_t id);
// struct group *getgrnam(const char name);
//
// struct group {
//   char *gr_name;   グループ名
//   char *gr_passwd; グループのパスワード
//   gid_t gr_git;    グループID
//   char **gr_mem;   グループのメンバ(ユーザー名のリスト)
// }
