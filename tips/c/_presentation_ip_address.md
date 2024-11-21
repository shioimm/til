```c
struct addrinfo *ai = ...;
char buff[INET6_ADDRSTRLEN];
void *src  = &(((struct sockaddr_in6 *)ai->ai_addr)->sin6_addr);

inet_pton(ai->ai_addr->sa_family, src, buf, sizeof(buf));
printf("%s\n", buff);
```

```c
struct addrinfo *ai = ...;
char buff[INET_ADDRSTRLEN];
void *src  = &(((struct sockaddr_in6 *)ai->ai_addr)->sin_addr);

inet_pton(ai->ai_addr->sa_family, src, buf, sizeof(buf));
printf("%s\n", buff);
```
