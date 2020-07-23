// 引用: ふつうのLinuxプログラミング
// 第5章 ストリームに関わるシステムコール 2

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h> // open(2)

int open(const char *path, int flags);
int open(const char *path, int flags, mode_t mode);

// pathの示すパスに位置するファイルにつながるストリームを生成
// -> 生成したストリームを指すファイルディスクリプタ番号を返す
//
//   flags ストリームの基本的な性質
//     O_RDONLY 読み込み専用
//     O_WRONLY 書き込み専用
//     O_RDWR   読み書き両用
//
//     O_WRONLY / O_RDWRオプション
//       O_CREAT           ファイルが存在しなければ新しいファイルを生成
//       O_CREAT + O_EXCL  すでにファイルが存在する場合はエラー
//       O_CREAT + O_TRUNC すでにファイルが存在する場合はファイルの長さを0にする
//       O_APPEND          write()がファイルの末尾に書き込むよう指定
//
//       mode O_CREATオプション
//         ファイルのパーミッションを指定

#include <unistd.h> // close(2)

int close(int fd);

// ファイルディスクリプタfd番に関連づけられているストリームを閉じる
// -> 0を返す
//    エラーが発生した場合 -1
//
// プロセスが終了した視点でそのプロセスが使っているストリームは全てカーネルが破棄する
// プロセスが開くことができるストリームの数には制限がある
