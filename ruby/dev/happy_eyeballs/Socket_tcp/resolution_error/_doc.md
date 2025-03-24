### `Socket::ResolutionError`クラス定義

```c
void
rsock_init_socket_init(void)
{
    // ...
    /*
     * Socket::ResolutionError is the error class for hostname resolution.
     */
    rb_eResolution = rb_define_class_under(rb_cSocket, "ResolutionError", rb_eSocket);
```

### `Socket::ResolutionError#error_code`

```c
/*
 * call-seq:
 *   error_code     -> integer
 *
 * Returns the raw error code indicating the cause of the hostname resolution failure.
 *
 *    begin
 *      Addrinfo.getaddrinfo("ruby-lang.org", nil)
 *    rescue Socket::ResolutionError => e
 *      if e.error_code == Socket::EAI_AGAIN
 *        puts "Temporary failure in name resolution."
 *      end
 *    end
 *
 * Note that error codes depend on the operating system.
 */
```
