// Software Design 2021年5月号 ハンズオンTCP/IP

#include <arpa/inet.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/ip_icmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
#include <poll.h>

#define BUFSIZE       1500
#define ECHO_HDR_SIZE 8

static int SendPing(int soc, char *name, int len, unsigned short sqc, struct timeval *sendtime)
{
  // WIP
}

static int RecvPing(int soc, int len, unsigned short sqc, struct timeval *sendtime, int timeoutSec)
{
  // WIP
}

int PingCheck(char *name, int len, int times, int timeoutSec)
{
  int soc;
  struct timeval sendtime;
  int ret;
  int total    = 0;
  int total_no = 0;

  if ((soc = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)) < 0) {
    return -300;
  }

  for (int i = 0; i < times; i++) {
    ret = SendPing(soc, name, len, i + 1, &sendtime);

    if (ret == 0) {
      ret = RecvPing(soc, len, i + 1, &sendtime, timeoutSec);

      if (ret >= 0) {
        total += ret;
        total_no++;
      }
    }
    sleep(1);
  }
  close(soc);

  if (total_no > 0) {
    return(total / total_no);
  } else {
    return -1
  }
}

int main(int argc, char *argv[])
{
  int ret;

  if (argc < 2) {
    fprintf(stderr, "ping target\n");
    return(EXIT_FAILURE);
  }

  ret = PingCheck(argv[1], 64, 5, 1);

  if (ret >= 0) {
    printf("RTT: %dms\n", ret);
    return(EXIT_SUCCESS);
  } else {
    printf("error: %d\n", ret);
    return(EXIT_FAILURE);
  }
}
