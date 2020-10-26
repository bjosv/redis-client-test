cmake_minimum_required(VERSION 3.14)
project(hiredis_vip_usage CXX)
include(ExternalProject)

# Use debug builds default
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
endif()

# Handle libevent
find_library(EVENT_LIBRARY event HINTS /usr/lib/x86_64-linux-gnu)

# Install directory for dependencies
set(INSTALL_DIR "${CMAKE_BINARY_DIR}/install")
file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

# Download and install: hiredis
ExternalProject_Add(hiredis_external
  GIT_REPOSITORY  https://github.com/redis/hiredis
  GIT_TAG         "v1.0.0"
  PREFIX          ${CMAKE_CURRENT_BINARY_DIR}
  CMAKE_ARGS      "-DENABLE_SSL=ON"
                  "-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}"
                  "-DCMAKE_BUILD_TYPE=Debug"
)

# Define lib: hiredis
add_library(hiredis STATIC SHARED IMPORTED)
add_dependencies(hiredis hiredis_external)
set_target_properties(hiredis PROPERTIES
  "IMPORTED_LOCATION" "${INSTALL_DIR}/lib/libhiredis.so"
  "INTERFACE_INCLUDE_DIRECTORIES" "${INSTALL_DIR}/include"
)

# Define lib: hiredis_ssl
add_library(hiredis_ssl STATIC SHARED IMPORTED)
add_dependencies(hiredis_ssl hiredis_external)
set_target_properties(hiredis_ssl PROPERTIES
  "IMPORTED_LOCATION" "${INSTALL_DIR}/lib/libhiredis_ssl.so"
  "INTERFACE_INCLUDE_DIRECTORIES" "${INSTALL_DIR}/include"
)

# Download and install: hiredis-vip
ExternalProject_Add(hiredis_vip_external
  # GIT_REPOSITORY    https://github.com/heronr/hiredis-vip
  # GIT_TAG           origin/master
  GIT_REPOSITORY    https://github.com/bjosv/hiredis-vip
  GIT_TAG           origin/heronr_corrections
  PREFIX            ${CMAKE_CURRENT_BINARY_DIR}
  CMAKE_ARGS        "-DCMAKE_PREFIX_PATH=${INSTALL_DIR}"
                    "-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}"
                    "-DCMAKE_BUILD_TYPE=Debug"
  BUILD_IN_SOURCE   1
  DEPENDS           hiredis
)

# Define lib: hiredis_vip
add_library(hiredis_vip STATIC SHARED IMPORTED)
add_dependencies(hiredis_vip hiredis_vip_external)
set_target_properties(hiredis_vip PROPERTIES
  "IMPORTED_LOCATION" "${INSTALL_DIR}/lib/libhiredis_vip.so"
  "INTERFACE_INCLUDE_DIRECTORIES" "${INSTALL_DIR}/include"
)

# Executable
add_executable(${PROJECT_NAME} main.cpp)
add_dependencies(${PROJECT_NAME} hiredis_vip hiredis)
target_link_libraries(${PROJECT_NAME} hiredis_vip hiredis)

# Executable: async
add_executable(${PROJECT_NAME}_async main_async.cpp)
add_dependencies(${PROJECT_NAME}_async hiredis_vip)
target_link_libraries(${PROJECT_NAME}_async hiredis hiredis_vip ${EVENT_LIBRARY})
