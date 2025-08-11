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

#define BUFSIZE 1500
#define ECHO_HEADER_SIZE sizeof(struct icmp)

struct round_trip {
    int time;
    int count;
};

static int send_ping(int sock, char *hostname, int len, unsigned short seq, struct timeval *sends_at)
{
    struct hostent *host;
    struct sockaddr_in *dest_addr;
    struct sockaddr dest_addr_storage;

    dest_addr = (struct sockaddr_in *)&dest_addr_storage;
    dest_addr->sin_family = AF_INET;
    dest_addr->sin_addr.s_addr = inet_addr(hostname);

    if (dest_addr->sin_addr.s_addr == INADDR_NONE) {
        host = gethostbyname(hostname);
        if (host == NULL) return -100;

        dest_addr->sin_family = host->h_addrtype;
        struct in_addr *addrp = &dest_addr->sin_addr;
        memcpy(addrp, host->h_addr, host->h_length);
    }

    gettimeofday(sends_at, NULL);

    struct icmp *icmp_header;
    unsigned char icmp_message[BUFSIZE];
    unsigned char *icmp_payload;
    int icmp_payload_size;

    memset(icmp_message, 0, BUFSIZE);
    icmp_header = (struct icmp *)icmp_message;
    icmp_header->icmp_type = ICMP_ECHO;
    icmp_header->icmp_code = 0;
    icmp_header->icmp_id = htons((uint16_t)getpid()); // 識別子にPIDを使用
    icmp_header->icmp_seq = htons(seq); // シーケンス番号を設定
    icmp_header->icmp_cksum = 0;

    icmp_payload = icmp_message + ECHO_HEADER_SIZE;
    icmp_payload_size = len - ECHO_HEADER_SIZE; // ICMPヘッダの直後を指すポインタをセット

    if (icmp_payload_size < (int)sizeof(struct timeval)) return -1;

    memcpy(icmp_payload, sends_at, sizeof(struct timeval));
    unsigned char *pads_at = icmp_payload + sizeof(struct timeval);
    int padding_size = icmp_payload_size - sizeof(struct timeval);
    memset(pads_at, 0xA5, padding_size);

    // WIP

    return 0; // WIP
}

int ping(char *hostname, int len, int times, int timeout, struct round_trip *rtt)
{
    int sock;
    int ret;

    if ((sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)) < 0) {
        perror("socket");
        return -300;
    }

    int total_round_trip_time = 0;
    int total_round_trip_count = 0;
    struct timeval sends_at;

    for (int i = 0; i < times; i++) {
        // static int send_ping(int sock, char *hostname, int len, unsigned short seq, struct timeval *sends_at);
        ret = send_ping(sock, hostname, len, i + 1, &sends_at);

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

    rtt->time = total_round_trip_time;
    rtt->count = total_round_trip_count;

    return 0;
}


int main(int argc,char *argv[])
{
    int ret;
    struct round_trip rtt;

    if (argc < 2) {
        fprintf(stderr, "Error! Missing ping target\n");
        return EXIT_FAILURE;
    }

    // int ping(char *hostname, int len, int times, int timeout, struct round_trip *rtt);
    ret = ping(argv[1], 64, 5, 1, &rtt);

    if (ret < 0) {
        printf("Error! %d\n", ret);
        return(EXIT_FAILURE);
    }

    double agv_rtt = (double)rtt.time / (double)rtt.count;

    printf("RTT: %.2fms\n", agv_rtt);
    return EXIT_SUCCESS;
}