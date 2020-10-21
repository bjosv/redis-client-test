cmake_minimum_required(VERSION 3.14)
project(hiredis_usage CXX)
include(ExternalProject)

# Use debug builds default
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
endif()

# Download and build dependency: hiredis
ExternalProject_Add(hiredis_external
  GIT_REPOSITORY  https://github.com/redis/hiredis
  GIT_TAG         "v1.0.0"
  CMAKE_ARGS      -DENABLE_SSL=ON
  PREFIX          ${CMAKE_CURRENT_BINARY_DIR}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND ""
  UPDATE_COMMAND  ""
)

# Define lib: hiredis
add_library(hiredis STATIC SHARED IMPORTED)
add_dependencies(hiredis hiredis_external)
set(HIREDIS_SRC_PATH "${CMAKE_CURRENT_BINARY_DIR}/src/hiredis_external/")
set_target_properties(hiredis PROPERTIES
  "IMPORTED_LOCATION" "${HIREDIS_SRC_PATH}/libhiredis.so"
  "INTERFACE_INCLUDE_DIRECTORIES" "${HIREDIS_SRC_PATH}"
)

# Define lib: hiredis_ssl
add_library(hiredis_ssl STATIC SHARED IMPORTED)
add_dependencies(hiredis_ssl hiredis_external)
set_target_properties(hiredis_ssl PROPERTIES
  "IMPORTED_LOCATION" "${HIREDIS_SRC_PATH}/libhiredis_ssl.so"
  "INTERFACE_INCLUDE_DIRECTORIES" "${HIREDIS_SRC_PATH}"
)

# Executable
add_executable(${PROJECT_NAME} main.cpp)
add_dependencies(${PROJECT_NAME} hiredis)
target_link_libraries(${PROJECT_NAME} hiredis)

# Executable: tls/ssl
add_executable(${PROJECT_NAME}_tls main_tls.cpp)
add_dependencies(${PROJECT_NAME}_tls hiredis)
target_link_libraries(${PROJECT_NAME}_tls hiredis hiredis_ssl)

# Executable: async
find_library(EVENT_LIBRARY event HINTS /usr/lib/x86_64-linux-gnu)

add_executable(${PROJECT_NAME}_async main_async.cpp)
add_dependencies(${PROJECT_NAME}_async hiredis)
target_link_libraries(${PROJECT_NAME}_async hiredis ${EVENT_LIBRARY})
