#include <stdio.h>
#include <stdlib.h>
#include "hiredis.h"

int main(int argc, char **argv)
{
    redisContext *c;
    struct timeval timeout = { 1, 500000 }; // 1.5s

    c = redisConnectWithTimeout("127.0.0.1", 32001, timeout);

    redisReply* reply = (redisReply*)redisCommand(c,"SET %s %s", "key", "value");
    printf("SET: %s\n", reply->str);
    freeReplyObject(reply);

    redisReply* reply2 = (redisReply*)redisCommand(c, "GET %s", "key");
    printf("GET: %s\n", reply2->str);
    freeReplyObject(reply2);

    /* Disconnects and frees the context */
    redisFree(c);
    return 0;
}
