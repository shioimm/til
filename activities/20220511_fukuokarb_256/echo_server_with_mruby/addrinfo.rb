Addrinfo.getaddrinfo('localhost',
                     12345,
                     Socket::AF_INET,
                     Socket::SOCK_STREAM,
                     nil,
                     Socket::AI_PASSIVE).first
