// 引用: ふつうのLinuxプログラミング
// 第14章 プロセスの環境 3

// クレデンシャル - カーネルが管理するプロセスの属性

// set-uidビット - 起動したユーザーに関わらず特定のユーザーの権限でファイルを実行するパーミッション
//   $ ls -l /usr/bin/passwd
//   -rwsr-xr-x  1 root  wheel  68656  9 21  2019 /usr/bin/passwd*
//     実行権限が"s"
//
//   #include <unistd.h>
//   #include <sys/types.h>
//   uid_t getuid();       実ユーザーIDを取得
//   uid_t geteuid();      実行ユーザーIDを取得
//   int setuid(uid_t id); 自プロセスの実ユーザーIDと実行ユーザーIDをidに変更
//
// set-gidビット - 起動したグループに関わらず特定のグループの権限でファイルを実行するパーミッション
//
//   #include <unistd.h>
//   #include <sys/types.h>
//   gid_t getgid();       実グループIDを取得
//   gid_t getegid();      実行グループIDを取得
//   int setgid(gid_t id); 自プロセスの実グループIDと実行グループIDをidに変更
//
//   #define _BSD_SOURCE
//   #include <grp.h>
//   #include <sys/types.h>
//   int initgroups(const char *user, git_t group); /etc/groupなどのDBを見てuserの捕捉グループをgroupに変更
//
// 完全に別ユーザーにする
//   1. rootとしてプログラムを起動
//   2. 変更先ユーザーのユーザー名/ID/グループIDを取得
//   3. setgid(変更先グループID)
//   4. initgroups(変更先ユーザー名, 変更先グループID)
//   5. setuid(変更先ユーザーID)
