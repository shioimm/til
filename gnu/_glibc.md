# GNU Cライブラリ(glibc)
- GNUプロジェクトにおける標準Cライブラリ実装
- GNUシステム、GNU/Linuxシステム、Linuxをカーネルとして使用するその他のシステムのためのコアライブラリ
  - 多くのプログラミング言語においてglibcは間接的に使用される
    - C#、Java、Perl、Python、Ruby etc
    - インタプリタ、VM、コンパイル済みコードは直接的にglibcを使用する
  - Ex. `open` `read` `write` `malloc` `printf` `getaddrinfo` `dlopen` `pthread_create` `crypt` `login` `exit`

### 代表的な機能
- メモリ管理
- プロセス管理
- 入出力
- ファイル操作
- 文字列処理
- 数学関数
- タイムゾーン・データベースなどの日付管理
- ユーザー管理
- 暗号処理 etc

### libc
- C言語の標準ライブラリ名

## 参照
-  [The GNU C Library (glibc)](https://www.gnu.org/software/libc/)
- [Glibc](https://ossfinder.linuxfoundation.jp/glossary/glibc)
- [glibc](https://xtech.nikkei.com/it/article/Keyword/20070308/264222/)
