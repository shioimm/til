# 2025/6/8時点

```c
struct rb_addrinfo*
rsock_getaddrinfo(VALUE host, VALUE port, struct addrinfo *hints, int socktype_hack)
{
    struct rb_addrinfo* res = NULL;
    struct addrinfo *ai;
    char *hostp, *portp;
    int error = 0;
    char hbuf[NI_MAXHOST], pbuf[NI_MAXSERV];
    int additional_flags = 0;

    hostp = raddrinfo_host_str(host, hbuf, sizeof(hbuf), &additional_flags);
    portp = raddrinfo_port_str(port, pbuf, sizeof(pbuf), &additional_flags);

    if (socktype_hack && hints->ai_socktype == 0 && str_is_number(portp)) {
        hints->ai_socktype = SOCK_DGRAM;
    }
    hints->ai_flags |= additional_flags;

    error = numeric_getaddrinfo(hostp, portp, hints, &ai);

    if (error == 0) {
        res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
        res->allocated_by_malloc = 1;
        res->ai = ai;
    } else {
        VALUE scheduler = rb_fiber_scheduler_current();
        int resolved = 0;

        if (scheduler != Qnil && hostp && !(hints->ai_flags & AI_NUMERICHOST)) {
            error = rb_scheduler_getaddrinfo(scheduler, host, portp, hints, &res);

            if (error != EAI_FAIL) {
                resolved = 1;
            }
        }

        if (!resolved) {
            error = rb_getaddrinfo(hostp, portp, hints, &ai);
            if (error == 0) {
                res = (struct rb_addrinfo *)xmalloc(sizeof(struct rb_addrinfo));
                res->allocated_by_malloc = 0;
                res->ai = ai;
            }
        }
    }

    if (error) {
        if (hostp && hostp[strlen(hostp)-1] == '\n') {
            rb_raise(rb_eSocket, "newline at the end of hostname");
        }
        rsock_raise_resolution_error("getaddrinfo", error);
    }

    return res;
}
```
