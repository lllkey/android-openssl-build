# Sets the minimum version of CMake required to build the native
# library. You should either keep the default value or only pass a
# value of 3.4.0 or lower.

cmake_minimum_required(VERSION 3.4.1)

message ("CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")

set(lib_type STATIC)
set(lib_suffix a)

#set(lib_type SHARED)
#set(lib_suffix so)

set(openssl_libs_DIR ${CMAKE_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/lib)
set(openssl_libs_include_DIR ${CMAKE_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/include)


add_library(xcrypto ${lib_type} IMPORTED)
set_target_properties(xcrypto PROPERTIES IMPORTED_LOCATION
             ${openssl_libs_DIR}/libcrypto.${lib_suffix})

add_library(xssl ${lib_type} IMPORTED)
set_target_properties(xssl PROPERTIES IMPORTED_LOCATION
             ${openssl_libs_DIR}/libssl.${lib_suffix})


add_library( native-lib

             SHARED

             src/main/cpp/native-lib.cpp
             src/main/cpp/openssl-jni.c )


target_include_directories(native-lib PUBLIC
  ${openssl_libs_include_DIR}
)



find_library( # Sets the name of the path variable.
              log-lib

              log )


target_link_libraries( # Specifies the target library.
                       native-lib xcrypto xssl dl

                       ${log-lib})
