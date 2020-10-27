.PHONY: start start-ipv4-tcp start-ipv6-tcp  start-ipv4-tls start-ipv6-tls start-single-tcp start-single-tls stop

REDIS_VER ?= 6.0.8

DOCKER_CONF = --net=host -v $(shell pwd)/configs/tls:/conf/tls:ro

# Redis cluster - common configs
REDIS_CLUSTER_CONF = --cluster-enabled yes --cluster-node-timeout 5000 --appendonly yes

# TLS - common configs
REDIS_TLS_CONF += --tls-ca-cert-file /conf/tls/ca.crt
REDIS_TLS_CONF += --tls-cert-file /conf/tls/redis.crt
REDIS_TLS_CONF += --tls-key-file /conf/tls/redis.key

# TLS Redis cluster - common configs
REDIS_CLUSTER_TLS_CONF = $(REDIS_CLUSTER_CONF) --tls-cluster yes $(REDIS_TLS_CONF)

start: start-ipv4-tcp start-ipv6-tcp start-ipv4-tls start-ipv6-tls \
	start-single-ipv4-tcp start-single-ipv6-tcp start-single-ipv4-tls start-single-ipv6-tls

# start_redis_cluster <name-tag> <bind-address>
define start_redis_cluster
	docker run --name redis-$(1)-tcp-1 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_CONF) --port 30001 --bind $(2)
	docker run --name redis-$(1)-tcp-2 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_CONF) --port 30002 --bind $(2)
	docker run --name redis-$(1)-tcp-3 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_CONF) --port 30003 --bind $(2)
	docker run --name redis-$(1)-tcp-4 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_CONF) --port 30004 --bind $(2)
	docker run --name redis-$(1)-tcp-5 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_CONF) --port 30005 --bind $(2)
	docker run --name redis-$(1)-tcp-6 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_CONF) --port 30006 --bind $(2)
	sleep 5
	echo 'yes' | docker run --name redis-cluster-setup -i --rm $(DOCKER_CONF) redis:$(REDIS_VER) \
	redis-cli --cluster create \
	$(2):30001 $(2):30002 $(2):30003 $(2):30004 $(2):30005 $(2):30006 \
	--cluster-replicas 1
endef

start-ipv4-tcp:
	$(call start_redis_cluster,ipv4,127.0.0.1)

start-ipv6-tcp:
	$(call start_redis_cluster,ipv6,::1)

# start_redis_cluster_tls <name-tag> <bind-address>
define start_redis_cluster_tls
	docker run --name redis-$(1)-tls-1 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_TLS_CONF) --port 0 --tls-port 31001 --bind $(2)
	docker run --name redis-$(1)-tls-2 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_TLS_CONF) --port 0 --tls-port 31002 --bind $(2)
	docker run --name redis-$(1)-tls-3 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_TLS_CONF) --port 0 --tls-port 31003 --bind $(2)
	docker run --name redis-$(1)-tls-4 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_TLS_CONF) --port 0 --tls-port 31004 --bind $(2)
	docker run --name redis-$(1)-tls-5 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_TLS_CONF) --port 0 --tls-port 31005 --bind $(2)
	docker run --name redis-$(1)-tls-6 -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_CLUSTER_TLS_CONF) --port 0 --tls-port 31006 --bind $(2)
	sleep 7
	echo 'yes' | docker run --name redis-cluster-setup -i --rm $(DOCKER_CONF) redis:$(REDIS_VER) \
	redis-cli --cluster create \
	--tls --cacert /conf/tls/ca.crt --cert /conf/tls/redis.crt --key /conf/tls/redis.key \
	$(2):31001 $(2):31002 $(2):31003 $(2):31004 $(2):31005 $(2):31006 \
	--cluster-replicas 1
endef

start-ipv4-tls:
	$(call start_redis_cluster_tls,ipv4,127.0.0.1)

start-ipv6-tls:
	$(call start_redis_cluster_tls,ipv6,::1)

# Start Redis node (non-cluster)
start-single-ipv4-tcp:
	docker run --name redis-single-ipv4-tcp -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server --port 32001 --bind 127.0.0.1
start-single-ipv6-tcp:
	docker run --name redis-single-ipv6-tcp -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server --port 32001 --bind ::1

start-single-ipv4-tls:
	docker run --name redis-single-ipv4-tls -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_TLS_CONF) --port 0 --tls-port 33001 --bind 127.0.0.1
start-single-ipv6-tls:
	docker run --name redis-single-ipv6-tls -d $(DOCKER_CONF) redis:$(REDIS_VER) redis-server $(REDIS_TLS_CONF) --port 0 --tls-port 33001 --bind ::1

# Stop all containers
stop:
	-docker rm -f redis-ipv4-tcp-1 redis-ipv4-tcp-2 redis-ipv4-tcp-3 redis-ipv4-tcp-4 redis-ipv4-tcp-5 redis-ipv4-tcp-6
	-docker rm -f redis-ipv4-tls-1 redis-ipv4-tls-2 redis-ipv4-tls-3 redis-ipv4-tls-4 redis-ipv4-tls-5 redis-ipv4-tls-6
	-docker rm -f redis-ipv6-tcp-1 redis-ipv6-tcp-2 redis-ipv6-tcp-3 redis-ipv6-tcp-4 redis-ipv6-tcp-5 redis-ipv6-tcp-6
	-docker rm -f redis-ipv6-tls-1 redis-ipv6-tls-2 redis-ipv6-tls-3 redis-ipv6-tls-4 redis-ipv6-tls-5 redis-ipv6-tls-6
	-docker rm -f redis-single-ipv4-tcp redis-single-ipv4-tls redis-single-ipv6-tcp redis-single-ipv6-tls
