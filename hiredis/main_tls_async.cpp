#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <string.h>
#include "hiredis.h"
#include "hiredis_ssl.h"
#include "adapters/libevent.h"

void setCallback(redisAsyncContext *c, void *r, void *privdata) {
    redisReply *reply = (redisReply*)r;
    if (reply == NULL) {
        if (c->errstr) {
            printf("errstr: %s\n", c->errstr);
        }
        return;
    }
    printf("privdata: %s reply: %s\n", (char*)privdata, reply->str);
}

void getCallback(redisAsyncContext *c, void *r, void *privdata) {
    redisReply *reply = (redisReply*)r;
    if (reply == NULL) {
        if (c->errstr) {
            printf("errstr: %s\n", c->errstr);
        }
        return;
    }
    printf("privdata: %s reply: %s\n", (char*)privdata, reply->str);

    /* Disconnect after receiving the reply to GET */
    redisAsyncDisconnect(c);
}

void connectCallback(const redisAsyncContext *c, int status) {
    if (status != REDIS_OK) {
        printf("Error: %s\n", c->errstr);
        return;
    }
    printf("Connected...\n");
}

void disconnectCallback(const redisAsyncContext *c, int status) {
    if (status != REDIS_OK) {
        printf("Error: %s\n", c->errstr);
        return;
    }
    printf("Disconnected...\n");
}

int main(int argc, char **argv)
{
    redisSSLContextError ssl_error;

    // Get current work directory
    char cwd[PATH_MAX];
    if (getcwd(cwd, sizeof(cwd)) == NULL) {
        printf("getcwd() error");
        exit(1);
    }
    printf("Current path: %s\n", cwd);

    char ca[PATH_MAX];
    strcpy(ca, cwd);
    strcat(ca, "/../../configs/tls/ca.crt");
    printf("Ca: %s\n", ca);
    char cert[PATH_MAX];
    strcpy(cert, cwd);
    strcat(cert, "/../../configs/tls/redis.crt");
    printf("Cert: %s\n", cert);
    char key[PATH_MAX];
    strcpy(key, cwd);
    strcat(key, "/../../configs/tls/redis.key");
    printf("Key: %s\n", key);

    redisInitOpenSSL();
    redisSSLContext *ssl = redisCreateSSLContext(ca, NULL, cert, key, NULL, &ssl_error);
    if (!ssl) {
        printf("Error: %s\n", redisSSLContextGetError(ssl_error));
        exit(1);
    }

    redisOptions options = {0};
    REDIS_OPTIONS_SET_TCP(&options, "127.0.0.1", 33001);
    struct timeval timeout = { 1, 500000 }; // 1.5s
    options.connect_timeout = &timeout;

    redisAsyncContext *c = redisAsyncConnectWithOptions(&options);
    if (c->err) {
        printf("Error: %s\n", c->errstr);
        exit(1);
    }
    if (redisInitiateSSLWithContext(&c->c, ssl) != REDIS_OK) {
        printf("SSL Error!\n");
        exit(1);
    }

    struct event_base *base = event_base_new();
    redisLibeventAttach(c, base);
    redisAsyncSetConnectCallback(c, connectCallback);
    redisAsyncSetDisconnectCallback(c, disconnectCallback);

    redisAsyncCommand(c, setCallback, (char*)"THE_ID", "SET %s %s", "key", "value");

    redisAsyncCommand(c, getCallback, (char*)"THE_ID", "GET %s", "key");

    event_base_dispatch(base);

    event_base_free(base);
    redisFreeSSLContext(ssl);
    return 0;
}
