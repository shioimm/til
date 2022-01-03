# クラス定義・メソッド定義
- `rb_define_class`: ruby/include/ruby/internal/module.h
  - トップレベルのクラスを定義
- `rb_define_class_under`: ruby/include/ruby/internal/module.h
  - 他のクラス／モジュールにネストしたクラスを定義
- `rb_singleton_class`: include/ruby/internal/intern/class.h
  - 特異クラス (`FL_SINGLETON`フラグが付き、インスタンスを一つだけ持つクラス) を定義
- `rb_define_module`: ruby/include/ruby/internal/module.h
  - トップレベルのモジュールを定義
- `rb_define_module_under`: include/ruby/internal/module.h
  - 他のクラス／モジュールにネストしたモジュールを定義
- `rb_define_method`: ruby/include/ruby/internal/method.h
  - メソッドを定義
- `rb_define_singleton_method`: ruby/include/ruby/internal/intern/class.h
  - 特異メソッドの定義

#### Init関数
- 組み込みクラス・モジュールオブジェクトとそれらに属するメソッドは
  各クラス・モジュールごとにInit関数に定義されている
- Init関数はrubyの起動時に明示的に呼び出される (`rb_call_inits`: ruby/inits.c)

## 参照
- [第4章 クラスとモジュール](https://i.loveruby.net/ja/rhg/book/class.html)
