#include <mruby.h>
#include <mruby/compile.h>

static mrb_value mrb_mruby_hello_initialize(mrb_state *mrb, mrb_value self)
{
  return self;
}

static mrb_value mrb_mruby_greeting(mrb_state *mrb, mrb_value self)
{
  return mrb_load_string(mrb, "puts 'Hello mruby'");
}

void mrb_mruby_hello_gem_init(mrb_state *mrb)
{
  struct RClass *hello_klass = mrb_define_class(mrb, "Hello", mrb->object_class);
  mrb_define_method(mrb, hello_klass, "initialize", mrb_mruby_hello_initialize, MRB_ARGS_NONE());
  mrb_define_method(mrb, hello_klass, "greeting",   mrb_mruby_greeting,         MRB_ARGS_NONE());
}

void mrb_mruby_hello_gem_final(mrb_state *mrb)
{
}

// build_config/default.rb
// conf.gem 'path/to/mruby-hello'を追加
//
// $ rake clean all
// $ bin/mruby -e 'puts Hello.new.greeting'
