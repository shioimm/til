# mruby
- 組み込みシステム向けの軽量なRuby言語処理系
- mruby VMを持ち、mruby VM上で動作する
  - Rubyスクリプトを動的にバイトコードに変換し、mruby VM上で実行する
  - 事前に生成したバイトコードを直接mruby VMに渡し、mruby VM上で実行する
- モジュール化されており、他のアプリケーション内にリンクして組み込むことが可能な設計となっている
- ソースコード・mgemを含めてワンバイナリとしてビルドすることができる

## 特徴
- コンパイラ言語
  - mruby VM上で動作し、環境に依存しない
  - バイトコードコンパイラmrbcを同梱
- C - mruby間での相互互換性・モジュラビリティ
- インクリメンタルGC
- 省メモリ

## mrubyのソースコードから作成されるバイナリ
### `bin/mruby`
- `mruby`コマンド (`$ ruby`に相当)
- `libmruby.a`を組み込んで任意のRubyスクリプトを実行できるようにしたバイナリ

```
$ echo 'p Hello.' > sample.rb
$ bin/mruby sample.rb
Hello
```

### `bin/mrbc`
- `mrbc`コマンド (バイトコードコンパイラ)

```
# 純粋なバイナリ形式のバイトコードを生成する
$ bin/mrbc sample.rb   # => sample.mrb (バイトコード)
$ bin/mruby sample.mrb # sample.mrbを実行
Hello

# Cのデータの配列形式のバイトコードを生成する
$ bin/mrbc -Bsample sample.rb # => sample.c (バイトコード)
$ echo -e "\
#include <mruby.h>\
#include <mruby/irep.h>\
#include "sample.c"\
\
int main()\
{\
  mrb_state *mrb = mrb_open();\
  if (!mrb) { /* handle error */ }\
  mrb_load_irep(mrb, mruby_in_c);\
  mrb_close(mrb);\
  return 0;\
}\
" > main.c
$ gcc -std=c99 -Imruby/include main.c -o main mruby/build/host/lib/libmruby.a -lm
$ ./main
Hello
```

### `bin/mirb`
- 対話型mrubyシェル(`$ irb`に相当)

```
$ bin/mirb
mirb - Embeddable Interactive Ruby Shell

> 'Hello.'
 => "Hello."
```

## 関連プロジェクト
- [Related Projects](https://github.com/mruby/mruby/wiki/Related-Projects)

## 参照
- [mruby/mruby](https://github.com/mruby/mruby)
- [Executing Ruby code with mruby](https://mruby.org/docs/articles/executing-ruby-code-with-mruby.html)
- Webで使えるmrubyシステムプログラミング入門 Section007
