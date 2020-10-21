# Redis client test

Prepare:

```
sudo apt install libevent-dev
```

## hiredis-vip

Simple usage of the lib

### Build

```
cd hiredis-vip/
mkdir build
cd build
cmake ..
make
```

## hiredis

Simple usage of the lib

### Build

```
cd hiredis/
mkdir build
cd build
cmake ..
make
```

## Other

Get RPATH

```
readelf -d ~/git/redis-client-test/hiredis-vip/build/hiredis_vip_usage | head -20
```

Get SONAME

```
objdump -p ~/git/redis-client-test/hiredis-vip/build/src/hiredis_vip_external/libhiredis_vip.so | grep SONAME
```
