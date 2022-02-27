#include <sys/socket.h> // socket(2), bind(2), setsockopt(2), listen(2), accept(2), shutdown(2)
                        // getaddrinfo(3), freeaddrinfo(3), gai_strerror(3)
#include <sys/types.h>  // getaddrinfo(3), freeaddrinfo(3), gai_strerror(3)
#include <netdb.h>      // getaddrinfo(3), freeaddrinfo(3), gai_strerror(3)
#include <string.h>     // memset(3), strlen(3)
#include <stdio.h>      // perror(3)
#include <stdlib.h>     // exit(3)
#include <unistd.h>     // read(2), write(2)

#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/string.h>
#include "addrinfo.c"

#define HOST "localhost"
#define PORT 12345
#define NQUEUESIZE 5
#define MAXMSGSIZE 1024

int main()
{
  mrb_state *mrb = mrb_open();

  // サーバーアドレス情報設定
  struct addrinfo server_addr_hints, *server_addr;
  int addrinfoerr;

  memset(&server_addr_hints, 0, sizeof(struct addrinfo));
  server_addr_hints.ai_family   = AF_INET;
  server_addr_hints.ai_socktype = SOCK_STREAM;
  server_addr_hints.ai_flags    = AI_PASSIVE;

  if ((addrinfoerr = getaddrinfo(NULL, "12345", &server_addr_hints, &server_addr)) < 0) {
    gai_strerror(addrinfoerr);
  }

  mrb_value addr = mrb_load_irep(mrb, addrinfo);
  mrb_value domain   = mrb_funcall(mrb, addr, "afamily",  0);
  mrb_value socktype = mrb_funcall(mrb, addr, "socktype", 0);
  mrb_value protocol = mrb_funcall(mrb, addr, "protocol", 0);

  // サーバーソケットの作成
  int listener;

  if ((listener = socket(mrb_integer(domain), mrb_integer(socktype), mrb_integer(protocol))) < 0) {
    perror("socket(2)");
    exit(1);
  }

  // サーバーアドレス再利用設定
  int reuse = 1;

  if (setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
    perror("setsockopt(2)");
    exit(1);
  }

  // WIP
  mrb_value port = mrb_funcall(mrb, addr, "ip_port",  0);
  char *ip_address = mrb_str_to_cstr(mrb, mrb_funcall(mrb, addr, "ip_address",  0));
  //htonlにunsigned intを渡さないといけない

  FILE *addr2info_src = fopen("addr2integer.rb", "r");
  mrb_load_file(mrb, addr2info_src);

  struct RClass *addr2integer = mrb_class_get(mrb, "Addr2Integer");

  // WIP
  mrb_value addr2integer_klass = mrb_obj_value(addr2integer);
  mrb_p(mrb, addr2integer_klass);
  // undefined method 'convert' (NoMethodError)になる
  mrb_value inaddr = mrb_funcall(mrb, addr2integer_klass, "convert", 1, "127.0.0,1");
  mrb_p(mrb, inaddr);
  fclose(addr2info_src);

  struct sockaddr_in saddr;
  saddr.sin_family      = mrb_integer(domain);
  saddr.sin_addr.s_addr = htonl(INADDR_ANY); // WIP
  saddr.sin_port        = htons(mrb_integer(port));

  // bind
  if (bind(listener, (struct sockaddr *)&saddr, sizeof(saddr)) < 0) {
    perror("bind(2)");
    exit(1);
  }

  // アドレス情報を解放
  freeaddrinfo(server_addr);

  // listen
  if (listen(listener, NQUEUESIZE) < 0) {
    perror("listen(2)");
    exit(1);
  }

  int conn;
  struct sockaddr_storage client_addr;
  socklen_t client_addr_len = sizeof(client_addr);

  char received_msg[MAXMSGSIZE];
  int  received_msg_size;

  for (;;) {
    // accept
    if ((conn = accept(listener, (struct sockaddr *)&client_addr, &client_addr_len)) < 0) {
      perror("accept(2)");
      exit(1);
    }

    // read / write
    if ((received_msg_size = read(conn, received_msg, MAXMSGSIZE)) < 0) {
      perror("read(2)");
      exit(1);
    }

    puts("--- Received ----");

    while (received_msg_size > 0) {
      if (write(conn, received_msg, received_msg_size) != received_msg_size) {
        perror("write(2)");
        exit(1);
      }

      printf("%.*s", received_msg_size, received_msg);

      if ((received_msg_size = read(conn, received_msg, MAXMSGSIZE)) < 0) {
        perror("read(2)");
        exit(1);
      }
    }

    // close(2)
    if (close(conn) < 0) {
      perror("close");
      exit(1);
    }
  }

  mrb_close(mrb);

  return 0;
}
