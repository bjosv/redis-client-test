.PHONY: start

REDIS_VER ?= 6.0.8

DOCKER_CONF = --net=host -v $(shell pwd)/priv/configs/tls:/conf/tls:ro

# Redis cluster - common configs
REDIS_CONF = --cluster-enabled yes --cluster-node-timeout 5000 --appendonly yes

start:
	docker run --name redis-1 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CONF) --port 30001
	docker run --name redis-2 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CONF) --port 30002
	docker run --name redis-3 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CONF) --port 30003
	docker run --name redis-4 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CONF) --port 30004
	docker run --name redis-5 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CONF) --port 30005
	docker run --name redis-6 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CONF) --port 30006
	sleep 5
	echo 'yes' | docker run --name redis-cluster -i --rm $(DOCKER_CONF) redis:$(REDIS_VER) \
	redis-cli --cluster create \
	127.0.0.1:30001 127.0.0.1:30002 127.0.0.1:30003 127.0.0.1:30004 127.0.0.1:30005 127.0.0.1:30006 \
	--cluster-replicas 1

stop:
	-docker rm -f redis-1 redis-2 redis-3 redis-4 redis-5 redis-6

status:
	docker run --name redis-cli -i --rm $(DOCKER_CONF) redis:$(REDIS_VER) \
	redis-cli -c -p 30001 CLUSTER INFO
