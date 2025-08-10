// Software Design 2021年5月号 ハンズオンTCP/IP
// pingを自作してネットワーク通信の実装を知る
#include <arpa/inet.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/ip_icmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include <poll.h>

int main(int argc,char *argv[])
{
    int ret;

    if (argc < 2) {
        fprintf(stderr, "Error! Missing ping target\n");
        return(EXIT_FAILURE);
    }

    ret = 1;

    if (ret < 0) {
        printf("Error! %d\n", ret);
        return(EXIT_FAILURE);
    }

    printf("RTT: %dms\n", ret);
    return(EXIT_SUCCESS);
}