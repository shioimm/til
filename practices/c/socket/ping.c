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

static int calc_checksum(register u_short *ptr, register int nbytes)
{
  register long    sum;
  u_short          oddbyte;
  register u_short answer;

  sum = 0;

  while(nbytes > 1) {
    sum    += *ptr++;
    nbytes -= 2;
  }

  if (nbytes == 1) {
    oddbyte = 0;
    *((u_char *)&oddbyte) = *(u_char *)ptr;
    sum += oddbyte;
  }

  sum  = (sum>>16) + (sum&0xffff);
  sum += (sum>>16);
  answer =~ sum;

  return answer;
}

static int SendPing(int soc, char *name, int len, unsigned short sqc, struct timeval *sendtime)
{
  struct hostent     *host;
  struct sockaddr_in *sinp;
  struct sockaddr     sa;
  struct icmphdr     *icp;
  unsigned char      *ptr;
  int                 psize;
  int                 n;
  char                sbuff[BUFSIZE];

  sinp = (struct sockaddr_in *)&sa;
  sinm->sin_family = AF_INET;

  if ((sinp->sin_addr.s_addr = inet_addr(name)) == INADDR_NONE) {
    host = gethostbyname(name);

    if (host == NULL) {
      return -100;
    }
    sinp->sin_family = host->h_addrtype;
    memcpy(&(sinp->sin_addr), host->h_addr, host->h_length);
  }

  gettimeofday(sendtime, NULL);

  memset(sbuf, 0, BUFSIZE);

  icp                   = (struct icmphdr *)sbuff;
  icp->type             = ICMP_ECHO;
  icp->code             = 0;
  icp->un.echo.id       = htons((unsigned short)getpid());
  icp->un.echo.sequence = htons(sqc);
  ptr                   = (unsigned char *)&sbuff[ECHO_HDR_SIZE];
  psize                 = len - ECHO_HDR_SIZE;

  for (; psize; psize--) {
    *ptr++ = (unsigned char)0xA5;
  }

  ptr = (unsigned char *)&sbuff[ECHO_HDR_SIZE];
  memcpy(ptr, sendtime, sizeof(struct timeval));

  icp->checksum = calc_checksum((u_short *)icp, len);
  n             = sendto(soc, sbuff, len, 0, &sa, sizeof(struct sockaddr));

  if (n == len) {
    return 0;
  } else {
    return -1000;
  }
}

static int check_packet(char *rbuff, int nbytes, int len, struct sockaddr_in *from, unsigned short sqc, int *ttl, struct timeval *sendtime, struct timeval, *recvtime, double *diff)
{
  struct iphdr   *iph;
  struct icmphdr *icp;
  int             i;
  unsigned char  *ptr;

  *diff = (double)(recvtime->tvsec - sendtime->tvsec) + (double)(recvtime->tv_usec - sendtime->tv_usec) / 1000000.0;
   iph  = (struct iphdr *)rbuff;
  *ttl  = iph->ttl;
   icp  = (struct icmphdr *)(rbuff + iph->ihl * 4);

  if (ntohs(icp->un.echo.id) != (unsigned short)getpid()) {
    return 1;
  }
  if (nbytes < len + iph->ihl * 4) {
    return -3000;
  }
  if (icp->type != ICMP_ECHOREPLY) {
    return -3010;
  }
  if (ntohs(icp->un.echo.sequence) != sqc) {
    return -3030;
  }

  ptr = (unsigned char *)(rbuff + iph->ihl * 4 + ECHO_HDR_SIZE);
  memcpy(sendtime, ptr, sizeof(struct timeval));

  ptr += sizeof(struct timeval);

  for (i = nbytes - iph->ihl * 4 - ECHO_HDR_SIZE - sizeof(struct timeval); i; i--) {
    if (*ptr++ != 0xA5) {
      return -3040;
    }
  }

  printf("%d bytes from %s: icmp_seq = %d ttl = %d time = %.2f ms\n",
         nbytes - iph->ihl * 4,
         inet_ntoa(from->sin_addr),
         sqc,
         *ttl,
         *diff * 1000.0);

  return 0;
}

static int RecvPing(int soc, int len, unsigned short sqc, struct timeval *sendtime, int timeoutSec)
{
  struct pollfd      targets[1];
  double             diff;
  int                nready;
  int                ret;
  int                nbytes;
  int                ttl;
  struct sockaddr_in from;
  socklen_t          fromlen;
  struct timeval     recvtime;
  char               rbuff[BUFSIZE];

  memset(rbuff, 0, BUFSIZE);

  for (;;) {
    targets[0].fd     = soc;
    targets[0].events = POLLIN|POLLERR;
    nready            = poll(targets, 1, timeoutSec * 1000);

    if (nready == 0) {
      return -2000;
    }
    if (nready == -1) {
      if (errno == EINTR) {
        continue;
      } else {
        return -2010;
      }
    }

    fromlen = sizeof(from);
    nbytes  = recvfrom(doc, rbuff, sizeof(rbuff), 0, (struct sockaddr *)&from, &fromlen);

    gettimeofday(&recvtime, NULL);

    ret = check_packet(rbuff, nbytes, len, &from, sqc, &ttl, sendtime, &recvtime, &diff);

    switch(ret) {
      case 0:
        return ((int)(diff * 1000.0));
      case 1:
        if (diff > (timeoutSec * 1000)) {
          return -2000;
        }
        break;
      default:
        ;
    }
  }
}

int PingCheck(char *name, int len, int times, int timeoutSec)
{
  int            soc;
  struct timeval sendtime;
  int            ret;
  int            total    = 0;
  int            total_no = 0;

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
