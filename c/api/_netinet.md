# `#include <netinet/in.h>`

```c
uint16_t htons(uint16_t host16bitvalue); // ホストバイトオーダ -> ネットワークバイトオーダ
uint32_t htonl(uint32_t host32bitvalue); // ホストバイトオーダ -> ネットワークバイトオーダ
uint16_t ntohs(uint16_t host16bitvalue); // ネットワークバイトオーダ -> ホストバイトオーダ
uint32_t ntohl(uint32_t host32bitvalue); // ネットワークバイトオーダ -> ホストバイトオーダ
```

- h: host
- n: network
- s: short (16bit)
- l: long (8bit)
