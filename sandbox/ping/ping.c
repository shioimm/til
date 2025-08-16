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
#define ECHO_HEADER_SIZE 8

struct round_trip {
    double time;
    int count;
};

struct ping_result {
    int received_bytes;
    struct in_addr *from;
    int seq;
    int ttl;
    double time;
};

static uint16_t
calc_checksum(const void *icmp_header, size_t len)
{
    const uint8_t *p = (const uint8_t *)icmp_header;
    uint32_t sum = 0;

    while (len >= 2) {
        uint8_t hi = p[0];
        uint8_t lo = p[1];
        uint16_t word = ((uint16_t)hi << 8) | (uint16_t)lo;
        sum += word;
        p += 2;
        len -= 2;
    }

    if (len == 1) {
        sum += (uint16_t)p[0] << 8;
    }

    while (sum >> 16) {
        sum = (sum & 0xFFFF) + (sum >> 16);
    }

    return (uint16_t)~sum;
}

static int
prepare_dest(struct sockaddr_in *dest, char *hostname)
{
    memset(dest, 0, sizeof(struct sockaddr_in));
    dest->sin_family = AF_INET;
    dest->sin_len = sizeof(*dest);

    if (inet_pton(AF_INET, hostname, &dest->sin_addr) == 1) return 0;

    struct addrinfo hints, *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_flags = AI_ADDRCONFIG;

    if (getaddrinfo(hostname, NULL, &hints, &res) != 0) return -1;

    memcpy(dest, res->ai_addr, sizeof(struct sockaddr_in));
    freeaddrinfo(res);

    return 0;
}

static void
prepare_icmp_header(struct icmp *icmp_header, unsigned short seq)
{
    icmp_header->icmp_type = ICMP_ECHO;
    icmp_header->icmp_code = 0;
    icmp_header->icmp_id = htons((uint16_t)getpid()); // 識別子にPIDを使用
    icmp_header->icmp_seq = htons(seq); // シーケンス番号を設定
    icmp_header->icmp_cksum = 0;
}

static int
prepare_icmp_payload(unsigned char *icmp_payload, int len, struct timeval *sends_at)
{
    int icmp_payload_size = len - ECHO_HEADER_SIZE; // ICMPヘッダの直後を指すポインタをセット
    if (icmp_payload_size < (int)sizeof(struct timeval)) return -1;

    memcpy(icmp_payload, sends_at, sizeof(struct timeval));

    unsigned char *pads_at = icmp_payload + sizeof(struct timeval);
    int padding_size = icmp_payload_size - sizeof(struct timeval);
    memset(pads_at, 0xA5, padding_size);

    return 0;
}

static int
send_ping(int sock, char *hostname, int len, unsigned short seq, struct timeval *sends_at)
{
    if (len > BUFSIZE) return -100;
    if (len < ECHO_HEADER_SIZE) return -100;

    struct sockaddr_in dest;
    if (prepare_dest(&dest, hostname) != 0) return -200;
    if (gettimeofday(sends_at, NULL) != 0) return -200;

    unsigned char icmp_message[BUFSIZE];
    memset(icmp_message, 0, (size_t)len);

    struct icmp *icmp_header;
    icmp_header = (struct icmp *)icmp_message;
    prepare_icmp_header(icmp_header, seq);

    unsigned char *icmp_payload;
    icmp_payload = icmp_message + ECHO_HEADER_SIZE;
    if (prepare_icmp_payload(icmp_payload, len, sends_at) != 0) return -1;

    uint16_t checksum = calc_checksum(icmp_message, (size_t)len);
    icmp_header->icmp_cksum = htons(checksum); 

    int ret = sendto(
        sock,
        icmp_message,
        len,
        0,
        (struct sockaddr *)&dest,
        sizeof(dest)
    );
    if (ret != len) return -1000;

    return 0;
}

// TOOD ping_result経由で渡せそうな引数を整理する
static int
check_packet(
    char *received_message,
    int read_bytes,
    int len,
    struct sockaddr_in *from,
    unsigned short seq,
    int *ttl,
    struct timeval *sends_at,
    struct timeval *received_at,
    double *past,
    struct ping_result *result
) {
    // WIP
    *past = 0.001;
    return 0;
}

static int
recv_ping(
    int sock,
    int len,
    unsigned short seq,
    struct timeval *sends_at,
    int timeout,
    struct ping_result *result
) {
    char received_message[BUFSIZE];
    memset(received_message, 0, BUFSIZE);
    struct pollfd pfd = { .fd = sock, .events = POLLIN | POLLERR };
    int nready;

    struct sockaddr_in from;
    socklen_t from_len = sizeof(from);

    int read_bytes;
    struct timeval received_at;

    int ret, ttl;
    double past;

    for (;;) {
        nready = poll(&pfd, 1, timeout * 1000);

        if (nready == 0) {
            return -2000; // タイムアウト
        }

        if (nready == -1) {
            if (errno == EINTR) continue;
            return -2010;
        }

        if (!(pfd.revents & POLLIN)) continue;

        read_bytes = recvfrom(
            sock,
            received_message,
            sizeof(received_message),
            0,
            (struct sockaddr *)&from,
            &from_len
        );

        if (gettimeofday(&received_at, NULL) != 0) return -200;

        ret = check_packet(
            received_message,
            read_bytes,
            len,
            &from,
            seq,
            &ttl,
            sends_at,
            &received_at,
            &past,
            result
        );

        switch(ret) {
            case 0: // 自プロセス宛のREPLYを正常に受信
                return past * 1000.0;
            case 1: // 他プロセス宛のREPLYを受信
                // TODO タイムアウトしている場合はreturn -2000
                break;
            default: // 自プロセス宛のREPLYだが内容が異常
                ;
      }
    }

    return 0; // WIP
}

int
ping(char *hostname, int len, int times, int timeout, struct round_trip *rtt)
{
    int sock;
    int ret;

    if ((sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)) < 0) {
        perror("socket");
        return -300;
    }

    double total_round_trip_time = 0.0;
    int total_round_trip_count = 0;
    struct timeval sends_at;
    struct ping_result result;

    for (int i = 0; i < times; i++) {
        // static int send_ping(int sock, char *hostname, int len, unsigned short seq, struct timeval *sends_at);
        ret = send_ping(sock, hostname, len, i + 1, &sends_at);

        if (ret == 0) {
            // static int recv_ping(int sock, int len, unsigned short seq, struct timeval *sends_at, int timeout, struct ping_result *result);
            ret = recv_ping(sock, len, i + 1, &sends_at, timeout, &result);
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


int
main(int argc, char *argv[])
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

    double agv_rtt = rtt.time / (double)rtt.count;

    printf("RTT: %.2fms\n", agv_rtt);
    return EXIT_SUCCESS;
}