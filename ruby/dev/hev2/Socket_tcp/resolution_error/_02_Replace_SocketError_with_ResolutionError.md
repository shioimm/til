# `rsock_raise_socket_error`のSocketErrorをSocket::ResolutionErrorで置き換える

```c
// ext/socket/init.c
// 変更
void
rsock_raise_socket_error(const char *reason, int error)
{
#ifdef EAI_SYSTEM
  int e;
  if (error == EAI_SYSTEM && (e = errno) != 0)
      rb_syserr_fail(e, reason);
#endif
#ifdef _WIN32
  rb_encoding *enc = rb_default_internal_encoding();
  VALUE msg = rb_sprintf("%s: ", reason);
  if (!enc) enc = rb_default_internal_encoding();
  rb_str_concat(msg, rb_w32_conv_from_wchar(gai_strerrorW(error), enc));
#else
  VALUE msg = rb_sprintf("%s: %s", reason, gai_strerror(error));
#endif

  StringValue(msg);
  VALUE self = rb_class_new_instance(1, &msg, rb_eResolutionError);
  rb_ivar_set(self, id_error_code, INT2NUM(error));
  rb_exc_raise(self);
}
```

#### テストの修正

```ruby
# test/fiber/test_address_resolve.rb
# ...
Fiber.schedule do
  assert_raise(Socket::ResolutionError) {
    Addrinfo.getaddrinfo("non-existing-domain.abc", nil)
  }
end
```

```ruby
# test/socket/test_addrinfo.rb
# ...

def test_error_message
  e = assert_raise_with_message(Socket::ResolutionError, /getaddrinfo/) do
    Addrinfo.ip("...")
  end
  # ...
end

def test_family_addrinfo
  # ...
  assert_raise(Socket::ResolutionError) { Addrinfo.tcp("0.0.0.0", 4649).family_addrinfo("::1", 80) }
end
```

```ruby
# test/socket/test_socket.rb
# ...

def test_getaddrinfo
  # This should not send a DNS query because AF_UNIX.
  assert_raise(Socket::ResolutionError) { Socket.getaddrinfo("www.kame.net", 80, "AF_UNIX") }
end

def test_getaddrinfo_raises_no_errors_on_port_argument_of_0
  # ...
  assert_raise(Socket::ResolutionError, '[ruby-core:29427]'){ Socket.getaddrinfo(nil, nil, Socket::AF_INET, Socket::SOCK_STREAM, nil, Socket::AI_CANONNAME) }
  # ...
end

def test_getnameinfo
  assert_raise(Socket::ResolutionError) { Socket.getnameinfo(["AF_UNIX", 80, "0.0.0.0"]) }
  # ...
end
```

#### テストの追加

```ruby
# test/socket/test_socket.rb
# ...

def test_resolurion_error_error_code
  begin
    Socket.getaddrinfo("www.kame.net", 80, "AF_UNIX")
  rescue => e
    assert_equal(e.error_code, Socket::EAI_FAMILY)
  end
end
```
