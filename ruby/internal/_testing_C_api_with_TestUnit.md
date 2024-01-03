# `ext/-test-/`

```
~/w/ruby ❯❯❯ ls ext/-test-/socket
./
../
extconf.rb
socket.c
```

```ruby
# extconf.rb
require 'mkmf'
create_makefile('-test-/socket')
```

```c
#include "ruby/ruby.h"

static VALUE
rb_getaddrinfo2(VALUE self)
{
    return rb_str_new_literal("OK");
}

void
Init_socket(void)
{
    VALUE mBug = rb_define_module("Bug");
    VALUE klass = rb_define_class_under(mBug, "Addrinfo", rb_cObject);
    rb_define_singleton_method(klass, "rb_getaddrinfo2", rb_getaddrinfo2, 0);
}
```

```
~/w/ruby ❯❯❯ ls test/-ext-/socket/
./
../
test_socket.rb
```

```
# frozen_string_literal: false
require 'test/unit'
require "-test-/socket"

class SocketTest < Test::Unit::TestCase
  def test_rb_getaddrinfo2
    assert_equal "OK", Bug::Addrinfo.rb_getaddrinfo2
  end
end
```
