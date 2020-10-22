cmake_minimum_required(VERSION 3.14)
project(hiredis_vip_usage CXX)
include(ExternalProject)

# Use debug builds default
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
endif()

# Handle libevent
find_library(EVENT_LIBRARY event HINTS /usr/lib/x86_64-linux-gnu)

# Download and build dependency: hiredis-vip
ExternalProject_Add(hiredis_vip_external
  GIT_REPOSITORY    https://github.com/bjosv/hiredis-vip
  GIT_TAG           "corrections"
  # GIT_REPOSITORY    https://github.com/vipshop/hiredis-vip
  # GIT_TAG           origin/master
  PREFIX            ${CMAKE_CURRENT_BINARY_DIR}
  BUILD_IN_SOURCE   1
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     make
  INSTALL_COMMAND   ln -s libhiredis_vip.so libhiredis_vip.so.1.0
  UPDATE_COMMAND    ""
)

# Define lib: hiredis_vip
add_library(hiredis_vip STATIC SHARED IMPORTED)
add_dependencies(hiredis_vip hiredis_vip_external)
set(HIREDIS_VIP_SRC_PATH "${CMAKE_CURRENT_BINARY_DIR}/src/hiredis_vip_external/")
set_target_properties(hiredis_vip PROPERTIES
  "IMPORTED_LOCATION" "${HIREDIS_VIP_SRC_PATH}/libhiredis_vip.so"
  "INTERFACE_INCLUDE_DIRECTORIES" "${HIREDIS_VIP_SRC_PATH}"
)

# Executable
add_executable(${PROJECT_NAME} main.cpp)
add_dependencies(${PROJECT_NAME} hiredis_vip)
target_link_libraries(${PROJECT_NAME} hiredis_vip)

# Executable: async
add_executable(${PROJECT_NAME}_async main_async.cpp)
add_dependencies(${PROJECT_NAME}_async hiredis_vip)
target_link_libraries(${PROJECT_NAME}_async hiredis_vip ${EVENT_LIBRARY})
