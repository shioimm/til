// 引用: ふつうのLinuxプログラミング
// 第10章 ファイルシステムに関わるAPI 1

// ディレクトリ
//   ファイルの情報を表す構造体の列
//
// ディレクトリエントリ
//   ディレクトリに含まれるファイルの情報を表す構造体

#include <sys/types.h>
#include <dirent.h>

DIR *opendir(const char *path);
// pathにあるディレクトリを読み込む
// -> DIR型へのポインタを返す
//      DIR型 構造体ストリームを管理する構造体

struct dirent *readdir(DIR *d);
// ディレクトリストリームdからエントリを一つ読み込む
// -> dirent構造体を返す
//    エントリがなくなった場合 NULL
//    読み込みに失敗した場合   NULL
//
//    dirent構造体
//      char *d_nameを持つ

int closedir(DIR *d);
// ディレクトリストリームdを閉じる
// -> 0を返す
//    失敗した場合 -1
