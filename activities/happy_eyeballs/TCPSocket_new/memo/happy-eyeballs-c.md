# CによるRFC6555実装 (参考)
- https://github.com/shtrom/happy-eyeballs-c/
  - https://github.com/shtrom/happy-eyeballs-c/blob/9bd5cf9ff10d53bf7958dab470e7aee84a497e76/main.c

```c
// SPDX-License-Identifier: GPL-3.0-or-later
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/select.h>
#include <sys/time.h>

#include <sys/timeb.h>

#define MAX(a,b) (((a)>(b))?(a):(b))

struct app_config {
  char *host;
  char *service;
};

int parse_argv(struct app_config *conf, int argc, char ** argv);
int connect_gai(char *host, char *service);
int connect_rfc6555(char *host, char *service);
int socket_create(struct addrinfo *rp);
int rfc6555(struct addrinfo *result, int sfd);
struct addrinfo *find_ipv4_addrinfo(struct addrinfo *result);
void print_delta(struct timeb *start, struct timeb *stop);
int try_read(int sfd);

int main(int argc, char **argv) {
  struct app_config conf;
  int ret = 0;
  int sfd = 0;
  struct timeb start_all, start, stop;

  if (0 != (ret = parse_argv(&conf, argc, argv))) {
    fprintf(stderr, "error: parsing arguments: %d\n", ret);
    fprintf(stderr, "usage: %s HOST PORT\n", argv[0]);
    return ret;
  }

  fprintf(stderr, "happy-eyeballing %s:%s ... \n", conf.host, conf.service);

  ftime(&start_all);
  ftime(&start);

  /* if((sfd = connect_gai(conf.host, conf.service)) < 0) */
  if((sfd = connect_rfc6555(conf.host, conf.service)) < 0) {
    fprintf(stderr, "error: connecting: %d\n", sfd);
    return sfd;
  }
  ftime(&stop);

  print_delta(&start, &stop);

  fprintf(stderr, "reading ...\n");

  ftime(&start);
  if ((ret = try_read(sfd)) < 0) {
    fprintf(stderr, "error: reading: %d\n", ret);
    return ret;
  }
  ftime(&stop);

  print_delta(&start, &stop);
  print_delta(&start_all, &stop);

  return ret;
}

int parse_argv(struct app_config *conf, int argc, char ** argv) {
  if (argc < 3) {
    return -1;
  }

  conf->host = strdup(argv[1]);
  conf->service = strdup(argv[2]);

  return 0;
}

/*
   Simple connection using getaddrinfo(3), from the manpage;
   licensing terms for this function can be found at [0].
   [0] http://man7.org/linux/man-pages/man3/getaddrinfo.3.license.html
 */
int connect_gai(char *host, char *service) {
  struct addrinfo hints;
  struct addrinfo *result, *rp;
  int sfd, s;

  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_UNSPEC;    /* Allow IPv4 or IPv6 */
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags |= AI_CANONNAME;
  hints.ai_protocol = 0;          /* Any protocol */

  s = getaddrinfo(host,service, &hints, &result);
  if (s != 0) {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(s));
    exit(EXIT_FAILURE);
  }

  /*
     getaddrinfo() returns a list of address structures.
     Try each address until we successfully connect(2).
     If socket(2) (or connect(2)) fails, we (close the socket and) try the next address.
   */

  for (rp = result; rp != NULL; rp = rp->ai_next) {
    fprintf(stderr, "connecting using rp %p (%s, af %d) ...",
        rp,
        rp->ai_canonname,
        rp->ai_family);
    sfd = socket(rp->ai_family, rp->ai_socktype,
        rp->ai_protocol);
    if (sfd == -1)
      continue;

    if (connect(sfd, rp->ai_addr, rp->ai_addrlen) != -1)
      break;                  /* Success */

    fprintf(stderr, " failed!\n");
    perror("error: connecting: ");
    close(sfd);
  }

  if (rp == NULL) {               /* No address succeeded */
    fprintf(stderr, "failed! (last attempt)\n");
    perror("error: connecting: ");
    return -3;
  }
  fprintf(stderr, " success!\n");

  freeaddrinfo(result);           /* No longer needed */

  return sfd;
}

/*
   Variation on the above, to implement RFC6555.
   Licensing terms for this function can be found at [0].
   [0] http://man7.org/linux/man-pages/man3/getaddrinfo.3.license.html
 */
int connect_rfc6555(char *host, char *service) {
  struct addrinfo hints;
  struct addrinfo *result, *rp;
  int sfd, s;

  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_UNSPEC;    /* Allow IPv4 or IPv6 */
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags |= AI_CANONNAME;
  hints.ai_protocol = 0;          /* Any protocol */

  s = getaddrinfo(host,service, &hints, &result);
  if (s != 0) {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(s));
    exit(EXIT_FAILURE);
  }

  /*
     getaddrinfo() returns a list of address structures.
     Try each address until we successfully connect(2).
     If socket(2) (or connect(2)) fails, we (close the socket and) try the next address.
   */

  for (rp = result; rp != NULL; rp = rp->ai_next) {
    sfd = socket_create(rp);
    if (sfd == -1)
      continue;

    if (connect(sfd, rp->ai_addr, rp->ai_addrlen) != -1)
      break;                  /* Success */

    if (EINPROGRESS == errno) {
      fprintf(stderr, " in progress ... \n");
      if((sfd = rfc6555(rp, sfd)) > -1)
        break;
    }

    perror("error: connecting: ");
    close(sfd);
  }

  if (rp == NULL) {               /* No address succeeded */
    fprintf(stderr, "failed! (last attempt)\n");
    perror("error: connecting: ");
    return -3;
  }
  fprintf(stderr, " success: %d!\n", sfd);

  freeaddrinfo(result);           /* No longer needed */

  return sfd;
}

int socket_create(struct addrinfo *rp) {
  int sfd;
  int flags;

  fprintf(stderr, "connecting using rp %p (%s, af %d) ...",
      rp,
      rp->ai_canonname,
      rp->ai_family);

  sfd = socket(rp->ai_family, rp->ai_socktype,
      rp->ai_protocol);
  if (sfd == -1)
    return -1;

  flags = fcntl(sfd, F_GETFL,0);
  fcntl(sfd, F_SETFL, flags | O_NONBLOCK);

  return sfd;
}

int rfc6555(struct addrinfo *result, int sfd) {
  fd_set readfds, writefds;
  int ret;
  struct addrinfo *rpv4;
  int sfdv4;

  struct timeval timeout = { 0, 300000 }; /* 300ms */

  FD_ZERO(&readfds);
  FD_ZERO(&writefds);
  FD_SET(sfd, &readfds);
  FD_SET(sfd, &writefds);

  fprintf(stderr, "info: waiting for 300ms ...\n");
  /* select with 300ms TO */
  if((ret = select(sfd+1, &readfds, &writefds, NULL, &timeout)) < 0)  {
    perror("error: initial timeout");
    return -1;
  }

  if (ret == 1) {
    return sfd;
  }

  fprintf(stderr, "info: still in progress, finding IPv4 ...\n");
  /* find IPv4 address */
  if(NULL == (rpv4 = find_ipv4_addrinfo(result->ai_next))) {
    fprintf(stderr, "error: none found, IPv6 selected\n");
    return sfd;
  }
  if (-1 == (sfdv4 = socket_create(rpv4))) {
    perror("error: setting up IPv4 socket");
    return sfd;
  }
  if (connect(sfdv4, rpv4->ai_addr, rpv4->ai_addrlen) != 0) {
    if (EINPROGRESS == errno) {
      fprintf(stderr, " in progress ... \n");
    } else {
      perror("error: connecting: ");
      close(sfdv4);
      return sfd;
    }
  }

  FD_ZERO(&readfds);
  FD_ZERO(&writefds);
  FD_SET(sfd, &readfds);
  FD_SET(sfdv4, &readfds);
  FD_SET(sfd, &writefds);
  FD_SET(sfdv4, &writefds);

  fprintf(stderr, "info: waiting for any socket ...\n");
  /* select with 300ms TO */
  if((ret = select(MAX(sfd,sfdv4)+1, &readfds, &writefds,
          NULL, NULL /* &timeout */)) < 0) {
    perror("error: second timeout");
    return -1;
  }

  if (ret >= 1) {
    if (FD_ISSET(sfd, &readfds) || FD_ISSET(sfd, &writefds)) {
      fprintf(stderr, "info: IPv6 selected\n");
      return sfd;
    }
    else if (FD_ISSET(sfdv4, &readfds) || FD_ISSET(sfdv4, &writefds)) {
      fprintf(stderr, "info: IPv4 selected\n");
      return sfdv4;
    }
  }
  return -1;
}

struct addrinfo *find_ipv4_addrinfo(struct addrinfo *result) {
  for (; result != NULL; result = result->ai_next) {
    fprintf(stderr, "info: considering %s (%d) ... \n",
        result->ai_canonname,
        result->ai_family);
    if (AF_INET == result->ai_family) {
      return result;
    }
  }
  return NULL;
}

void print_delta(struct timeb *start, struct timeb *stop) {
  fprintf(stderr, "delta: %lds %dms\n", stop->time - start->time, stop->millitm-start->millitm);
}

int try_read(int sfd) {
  char buf[1024];
  ssize_t s;

  while((s = read(sfd, buf, sizeof(buf))) < 0) {
    if (EAGAIN != errno) {
      perror("error: reading: ");
      return -4;
    }
  }

  fprintf(stderr, "read: ");
  printf("%s\n", buf);

  return 0;
}
```
