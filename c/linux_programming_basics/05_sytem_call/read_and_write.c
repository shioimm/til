// 引用: ふつうのLinuxプログラミング
// 第5章 ストリームに関わるシステムコール 1
//
// 実行中のプロセスでリソースを開くとファイルディスクリプタ番号が割り当てられる

#include <unistd.h> // read(2) / write(2)

ssize_t read(int fd, void *buf, size_t bufsize);
//   ファイルディスクリプタfd番のストリームから
//   最大bufsizeバイト分のバイト列を読み込み、
//   bufに格納する
//   -> 読み込んだバイト数を返す
//        ファイル終端に達した場合 0
//        エラーが発生した場合     -1
//
//   ssize_t / size_t OSの違いによる整数型の違いを吸収するための型
//     ssize_t 符号付整数型
//     size_t  符号無し整数型
//
//   read()は'\0'終端を前提としない
//     printf()は'\0'終端を前提とする

ssize_t write(int fd, const void *buf, size_t bufsize);

// bufから
// ファイルディスクリプタfd番のストリームへ
// 最大bufsizeバイト分のバイト列を書き込む
// -> 書き込んだバイト数を返す
//    エラーが発生した場合 -1
