# 案
- メソッド開始時点からのタイムアウト `open_timeout`
- Resolution Delay中、Connection Attempt Delay中の場合はよりタイムアウト時間が短い方を取る
- 既存のタイムアウト値と同時に設定した場合は`open_timeout`を優先し、他のタイムアウトは無視
  - 同時に指定すると例外を上げる、なども考えられるが、
    将来的に`connect_timeout`を同時接続数の制限に使うような仕様に変更する方向性があるかもしれない
    - `open_timeout`で全体のタイムアウトを指定しつつ、`connect_timeout`でを同時接続数を制限する
    - 「同時指定で例外」のような強い制約があるとこのような変更を入れづらい

```
diff --git a/ext/socket/lib/socket.rb b/ext/socket/lib/socket.rb
index 60dd45bd4f..5f3aa9c428 100644
--- a/ext/socket/lib/socket.rb
+++ b/ext/socket/lib/socket.rb
@@ -656,11 +656,11 @@ def accept_nonblock(exception: true)
   #     sock.close_write
   #     puts sock.read
   #   }
-  def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback, &) # :yield: socket
+  def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, open_timeout: nil, fast_fallback: tcp_fast_fallback, &) # :yield: socket
     sock = if fast_fallback && !(host && ip_address?(host))
-      tcp_with_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:)
+      tcp_with_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, open_timeout:)
     else
-      tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:)
+      tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, open_timeout:)
     end

     if block_given?
@@ -674,7 +674,7 @@ def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: ni
     end
   end

-  def self.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil)
+  def self.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, open_timeout: nil)
     if local_host || local_port
       local_addrinfos = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, timeout: resolv_timeout)
       resolving_family_names = local_addrinfos.map { |lai| ADDRESS_FAMILIES.key(lai.afamily) }.uniq
@@ -692,6 +692,7 @@ def self.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil,
     resolution_delay_expires_at = nil
     connection_attempt_delay_expires_at = nil
     user_specified_connect_timeout_at = nil
+    user_specified_open_timeout_at = open_timeout ? now + open_timeout : nil
     last_error = nil
     last_error_from_thread = false

@@ -784,7 +785,10 @@ def self.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil,

       ends_at =
         if resolution_store.any_addrinfos?
-          resolution_delay_expires_at || connection_attempt_delay_expires_at
+          [(resolution_delay_expires_at || connection_attempt_delay_expires_at),
+           user_specified_open_timeout_at].compact.min
+        elsif user_specified_open_timeout_at
+          user_specified_open_timeout_at
         else
           [user_specified_resolv_timeout_at, user_specified_connect_timeout_at].compact.max
         end
@@ -886,6 +890,8 @@ def self.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil,
       end

       if resolution_store.empty_addrinfos?
+        raise(Errno::ETIMEDOUT, 'user specified timeout') if expired?(now, user_specified_open_timeout_at)
+
         if connecting_sockets.empty? && resolution_store.resolved_all_families?
           if last_error_from_thread
             raise last_error.class, last_error.message, cause: last_error
@@ -912,7 +918,7 @@ def self.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil,
     end
   end

-  def self.tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:)
+  def self.tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, open_timeout:)
     last_error = nil
     ret = nil

diff --git a/test/socket/test_socket.rb b/test/socket/test_socket.rb
index 165990dd64..9bd1056185 100644
--- a/test/socket/test_socket.rb
+++ b/test/socket/test_socket.rb
@@ -937,6 +937,23 @@ def test_tcp_socket_resolv_timeout_with_connection_failure
     RUBY
   end

+  def test_tcp_socket_open_timeout
+    opts = %w[-rsocket -W1]
+    assert_separately opts, <<~RUBY
+    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
+      if family == Socket::AF_INET6
+        sleep
+      else
+        [Addrinfo.tcp("127.0.0.1", 12345)]
+      end
+    end
+
+    assert_raise(Errno::ETIMEDOUT) do
+      Socket.tcp("localhost", 12345, open_timeout: 0.01)
+    end
+    RUBY
+  end
```
