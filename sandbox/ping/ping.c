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

int ping(char *hostname, int len, int times, int timeout)
{
    int sock;
    int ret;

    if ((sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)) < 0) {
        perror("socket");
        return -300;
    }

    int total_round_trip_time = 0;
    int total_round_trip_count = 0;

    for (int i = 0; i < times; i++) {
        ret = 0; // TODO Send ICMP Echo Request

        if (ret == 0) {
            ret = 1; // TODO Receive ICMP Echo Reply
            if (ret >= 0) {
                total_round_trip_time += ret;
                total_round_trip_count++;
            }
        }
        sleep(1);
    }

    close(sock);

    if (total_round_trip_count == 0) return -1;

    // TODO
    // total_round_trip_timeとtotal_round_trip_countの値を構造体に持たせる
    // 往復時間はmainで計算する
    // 返り値は成功・失敗の結果のみ返すようにする
    return total_round_trip_time / total_round_trip_count;
}


int main(int argc,char *argv[])
{
    int ret;

    if (argc < 2) {
        fprintf(stderr, "Error! Missing ping target\n");
        return EXIT_FAILURE;
    }

    // ping(char *name, int len, int times, int timeout)
    ret = ping(argv[1], 64, 5, 1);

    if (ret < 0) {
        printf("Error! %d\n", ret);
        return(EXIT_FAILURE);
    }

    printf("RTT: %dms\n", ret);
    return EXIT_SUCCESS;
}