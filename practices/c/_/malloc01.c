#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/string.h>
#include <mruby/variable.h>
#include <stdio.h>

#include <stdio.h>
#include <stdlib.h>

typedef struct {
  char *str;
} foo_t;

foo_t *foo;

void alloc_and_assign()
{
  mrb_state *mrb = mrb_open();

  mrb_value f = mrb_load_string(mrb, "class F;def initialize;@f = 'foo';end;end;F.new");
  mrb_value _f = mrb_iv_get(mrb, f, mrb_intern_lit(mrb, "@f"));

  char *str = mrb_str_to_cstr(mrb, _f);

  if ((foo = malloc(sizeof(foo))) == NULL) {
    perror("malloc");
  }

  foo->str = str;
  mrb_close(mrb);
}

int main()
{
  alloc_and_assign();

  printf("%s\n", foo->str);

  free(foo);
}
