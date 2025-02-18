// 引用: ふつうのLinuxプログラミング
// 第5章 ストリームに関わるシステムコール 4
//
// 同じファイルディスクリプタから繰り返し読み込みを行う場合、
// read()システムコールは前回読み込んだ続きを返す
//   -> ストリームはファイルを読み込んだ地点(ファイルオフセット)に繋がっている

#include <sys/types.h>
#include <unistd.h> // lseek(2) / dup(2) / dup2(2)

off_t lseek(int fd, off_t offset, int whence);

// ファイルディスクリプタfd内部のファイルオフセットの指定した位置offsetに移動する
//
//   whence 位置の指定方法
//     SEEK_SET offsetに移動
//     SEEK_CUR 現在のファイルオフセット + offsetに移動
//     SEEK_END ファイル末尾 + offsetに移動

int dup(int oldfd);
int dup2(int oldfd, int newfd);

// ファイルディスクリプタfdを複製する
//
//   du p 未使用のディスクリプタのうちディスクリプタ番号が最も小さいものを新しいディスクリプタとして使用
//   dup2 未使用のディスクリプタのうちnewfdで指定したディスクリプタ番号のものを新しいディスクリプタとして使用

#include <sys/ioctl.h> // ioctl()

int ioctl(int fd, unsigned long request, ...);

// ストリームがつながる先にあるデバイスに特化した操作を行う
//
//   request     どのような操作をするか
//   第3引数以降 request特有の引数

#include <unistd.h>
#include <fcntl.h>

int fcntl(int fd, int cmd, ...);

// cmdによって指定された操作を行う
//   fcntl(fd, F_DUPED) == dup(fd)
