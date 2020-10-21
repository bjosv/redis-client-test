#include <stdio.h>
#include <stdlib.h>
#include "hiredis.h"
#include "adapters/libevent.h"

void getCallback(redisAsyncContext* c, void* r, void* privdata) {
    redisReply* reply = (redisReply*)r;
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

void connectCallback(const redisAsyncContext* c, int status) {
    if (status != REDIS_OK) {
        printf("Error: %s\n", c->errstr);
        return;
    }
    printf("Connected...\n");
}

void disconnectCallback(const redisAsyncContext* c, int status) {
    if (status != REDIS_OK) {
        printf("Error: %s\n", c->errstr);
        return;
    }
    printf("Disconnected...\n");
}

int main(int argc, char **argv)
{
    redisOptions options = {0};
    REDIS_OPTIONS_SET_TCP(&options, "127.0.0.1", 32001);
    struct timeval timeout = { 1, 500000 }; // 1.5s
    options.connect_timeout = &timeout;

    redisAsyncContext* c = redisAsyncConnectWithOptions(&options);
    if (c->err) {
        printf("Error: %s\n", c->errstr);
        return 1;
    }

    struct event_base* base = event_base_new();
    redisLibeventAttach(c, base);
    redisAsyncSetConnectCallback(c, connectCallback);
    redisAsyncSetDisconnectCallback(c, disconnectCallback);

    redisAsyncCommand(c, NULL, NULL, "SET %s %s", "key", "value");

    redisAsyncCommand(c, getCallback, (char*)"THE_ID", "GET %s", "key");

    event_base_dispatch(base);
    return 0;
}
