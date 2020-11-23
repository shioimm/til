# mrbgem-template
- 参照: [mruby-mrbgem-template](https://github.com/matsumotory/mruby-mrbgem-template)
- 参照: Webで使えるmrubyシステムプログラミング入門 Section019

## TL;DR
- mgemの雛形を生成するコマンド

## Getting Started
```
# コマンドのインストール
$ brew tap mrbgems/mrbgem-template
$ brew install mrbgem-template

# 雛形の生成
$ mrbgem-template -m mrubyのバージョン 作成するmgemの名前

# バイナリも一緒に生成する場合
$ mrbgem-template -m mrubyのバージョン --bin-name バイナリの名前 作成するmgemの名前
# -> バイナリの名前.cファイルが生成され、作成するバイナリのスタートポイントになる

# mgemディレクトリへ移動
$ cd ./mgemの名前

# ビルド時は逐次バイナリを実行するマシンでrakeを実行
$ rake
# -> mruby/ディレクトリを作り、mrubyのソースコードをチェックアウトする
```

## 生成されるファイル群
- `Rakefile`
  - テスト、ビルド用
- `mrbgem.rake`
  - mgemのビルドに必要な情報を記述する(`build_config.rb`のようなもの)
- `作成したmgemの名前.gem`
  - 作成したmgemの説明をYAML形式で記述する
  - mgemのインストールにあたって内部で利用する
  - mgem-listに公開される
- `mruby/`
  - 動作確認のためmrubyのソースコードをチェックアウトするディレクトリ
  - `$ rake`コマンドを実行することで自動的にmrubyのソースコードをダウンロードする
- `mrblib/`
  - Rubyで書かれたmgemのソースコードを配置するディレクトリ
  - `mrblib`配下のファイルは自動で辞書順に全て読み込まれる
- `src/`
  - Cで書かれたmgemのソースコードを配置するディレクトリ
- `test/`
  - テストコードを配置するディレクトリ
- `tools/`
  - 作成したmgemに添付するコマンドラインツールを配置する

## Rubyスクリプト用ファイルテンプレート
- `mgemの名前/mrblib/mgemの名前.rb`
```ruby
class mgemの名前
  def bye
    self.hello + "bye"
  end

  # バイナリを一緒に作成した場合に追加される
  # このメソッド内に記述した内容は $ path/to/バイナリの名前 で実行可能
  def __main__(argv) # argv - 定数ARGV
    raise NotImplementedError, "Please implement Kernel#__main__ in your .rb file"
  end
end
```
## C用ファイルテンプレート
- `mgemの名前/src/mrb_mgemの名前.c`
```c
#include "mruby.h"
#include "mruby/data.h"
#include "mrb_mgemの名前.h"

# Cでのmrubyメソッド定義の際に中間的に作られるmrubyオブジェクトを
# 効率よく回収するための関数マクロ
#define DONE mrb_gc_arena_restore(mrb, 0);

typedef struct {
  char *str;
  mrb_int len;
} mrb_mgemの名前_data;

static const struct mrb_data_type mrb_mgemの名前_data_type = {
  "mrb_mgemの名前_data", mrb_free,
};

static mrb_value mrb_mgemの名前_init(mrb_state *mrb, mrb_value self)
{
  mrb_mgemの名前_data *data;
  char *str;
  mrb_int len;

  data = (mrb_mgemの名前_data *)DATA_PTR(self);
  if (data) {
    mrb_free(mrb, data);
  }
  DATA_TYPE(self) = &mrb_mgemの名前_data_type;
  DATA_PTR(self) = NULL;

  mrb_get_args(mrb, "s", &str, &len);
  data = (mrb_mgemの名前_data *)mrb_malloc(mrb, sizeof(mrb_mgemの名前_data));
  data->str = str;
  data->len = len;
  DATA_PTR(self) = data;

  return self;
}

static mrb_value mrb_mgemの名前_hello(mrb_state *mrb, mrb_value self)
{
  mrb_mgemの名前_data *data = DATA_PTR(self);

  return mrb_str_new(mrb, data->str, data->len);
}

static mrb_value mrb_mgemの名前_hi(mrb_state *mrb, mrb_value self)
{
  return mrb_str_new_cstr(mrb, "hi!!");
}

# mgemの読み込み時に最初に呼ばれる関数
void mrb_mgemの名前_gem_init(mrb_state *mrb)
{
  struct RClass *mgemの名前;
  mgemの名前 = mrb_define_class(mrb, "Example", mrb->object_class);
  mrb_define_method(mrb, mgemの名前, "initialize", mrb_mgemの名前_init, MRB_ARGS_REQ(1));
  mrb_define_method(mrb, mgemの名前, "hello", mrb_mgemの名前_hello, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, mgemの名前, "hi", mrb_mgemの名前_hi, MRB_ARGS_NONE());
  DONE;
}

# mgemの終了時に呼ばれる関数
void mrb_mgemの名前_gem_final(mrb_state *mrb)
{
}
```
