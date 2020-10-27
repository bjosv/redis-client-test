# Redis client test

A couple of simple testprograms that uses some existing Redis client libraries in C.
Each folder covers a single client library, and CMake is used to download needed
libraries and to build the test programs.

Prepare:

```
# Install: cmake, gcc/clang (valgrind)

# Needed for async behaviour
sudo apt install libevent-dev

# Start Redis clusters/instances
make start

(use `make stop` to stop them again later)
```

## hiredis

Simple usage of the official library.

### Build

```
cd hiredis/
mkdir build
cd build
cmake ..
make
```

## hiredis-vip

Simple usage of the library supporting Redis Cluster
This library is built on top of an older hiredis.

### Build

```
cd hiredis-vip/
mkdir build
cd build
cmake ..
make
```

### Findings

Problems found in the hiredis-vip:

* Not supporting IPv6
  int redisClusterSetOptionAddNode(redisClusterContext *cc, const char *addr)
  Using `:` to split address and port, wont work in IPv6

## hiredis-vip (heronr fork)

Simple usage of the library supporting Redis Cluster.
This library links to an official hiredis.

### Build

```
cd hiredis-vip-heronr/
mkdir build
cd build
cmake ..
make
```

### Findings

Problems found in the hiredis fork:

* Include path errors:
  sed -i s/adapaters/adapters/ ${CMAKE_BINARY_DIR}/src/hiredis_vip_external/adapters/libevent.h
* Spelling: witch
  static cluster_node *node_get_witch_connected(redisClusterContext *cc)
* Leak: Iterator not released
  void redisClusterAsyncDisconnect(redisClusterAsyncContext *acc)
* Faulty pointer
  static void unlinkAsyncContextAndNode(redisAsyncContext* ac)
  -->
  static void unlinkAsyncContextAndNode(void *data)
        node = (cluster_node *)(data);
* Spelling
  - redisCLusterSendAll
  - redisCLusterClearAll
* Unused functions
  - static void print_cluster_node_list(redisClusterContext *cc)
  - static cluster_node *node_get_by_slot(redisClusterContext *cc, uint32_t slot_num)


## Checkers

```
docker run -t -v $(pwd):/src neszt/cppcheck-docker
```
