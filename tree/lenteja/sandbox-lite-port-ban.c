#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdint.h>
#include <sys/socket.h>

static const uint16_t banned_ports[] = {
    // 4000,
};
static const size_t num_banned_ports = sizeof(banned_ports) / sizeof(*banned_ports);

typedef int (*connect_func_t)(int, const struct sockaddr *, socklen_t);

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    if (addr && addr->sa_family == AF_INET) {
        struct sockaddr_in *sin = (struct sockaddr_in *)addr;
        in_addr_t ip = sin->sin_addr.s_addr;
        if (ip == htonl(INADDR_LOOPBACK) || ip == htonl(INADDR_ANY)) {
            uint16_t target_port = ntohs(sin->sin_port);
            for (size_t i = 0; i < num_banned_ports; i++) {
                if (target_port == banned_ports[i]) {
                    errno = ECONNREFUSED;
                    return -1;
                }
            }
        }
    }

    connect_func_t orig = (connect_func_t)dlsym(RTLD_NEXT, "connect");
    return orig(sockfd, addr, addrlen);
}