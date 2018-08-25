# android-openssl-build
ndk编译openssl，"armeabi-v7a" "arm64-v8a" "x86" "x86_64" "mip" "mip_64"

* openssl版本：[https://www.openssl.org/source/](https://www.openssl.org/source/)
* 参考：
>* [openssl教程](https://wiki.openssl.org/index.php/Android)
>* [openssl推荐的Setenv-android.sh](https://wiki.openssl.org/images/7/70/Setenv-android.sh)
>* [ios的openssl编译：https://github.com/palmerc/CMake_OpenSSL](https://github.com/palmerc/CMake_OpenSSL)
* 目录：
    * compile-openssl-android.sh：主要运行程序。
    * Setenv-android-input.sh：需要调用的设置环境变量程序，基于Setenv-android.h。
    * result：编译完成的结果目录。
    * openssl_change：修改的openssl中的文件。

## 运行方法
* 1 按照本地ndk和openssl路径修改compile-openssl-android.sh中相关定义
>* **_ANDROID_NDK_ROOT**：ndk绝对路径
>* **_OPENSSL_GCC_VERSION**：gcc版本号：从ndk绝对路径/toolchains中看后面的版本号
>* **_ANDROID_API**：从ndk绝对路径/platforms中找到合适的安卓的版本
>* **_OPENSSL_ROOT**：openssl的绝对路径
>* **_INSTALL_ROOT**：生成的文件的绝对路径
* 2 运行compile-openssl-android.sh文件
* 3 将编译结果复制到`/testJniOpenssl/app/src/main/jniLibs`目录中，运行android项目
```./compile-openssl-android.sh```

## 主要工作
### 文件compile-openssl-android.sh
* 循环各个架构，分别编译。
* 步骤：
>* 1 创建结果目录
>* 2 根据架构做不同变量设置
>* 3 设置结果目录
>* 4 设置到openssl源码目录，开始在此目录工作
>* 5 clean 
>* 6 调用say_hello配置各种环境变量
>* 7 配置openssl，config
>* 8 编译，make depend， make。。。
>* 9 创建结果目录的lib和include，并将结果复制进去。

* 除了上述运行方法中提到的之外，其中主要变量含义如下：
>* **BUILD_SHARED**：是否编译so。
>* **BUILD_CLANG**：本来考虑使用clang编译，但是现在失败，但是不用。
>* **basepath**：当前sh调用目录，方便Setenv-android-input.sh的调用。
>* **PLATFORM_LIBRARY_PREFIX**：生成的库的前缀，libssl.so，如：lib。
>* **STATIC_LIBRARY_SUFFIX**：静态库后缀，如：.a。
>* **SHARED_LIBRARY_SUFFIX**：动态库后缀，如：.so。
>* **OPENSSL_MODULES**：生成的库名称。
>* **NCPU**：make线程数。
>* **OPENSSL_LIBRARIES**：最终的生成库的全称数组。如：libssl.a libssl.so。。。
>* **TARGET_ARCHITECTURE**：当前架构，如：x86_64
>* **INSTALL_DIR**：安装目录，基于_INSTALL_ROOT目录之后得到的当前架构的目录。
>* **SOURCE_DIR**：openssl的目录。
>* **ANDROID_EABI_PREFIX**：方便之后的前缀调用，如：x86_64-linux-android。
>* **ANDROID_DEV_INCLUDE_ROOT**：可能包含头文件的目录名称，目前与ANDROID_EABI_PREFIX相同。
>* **ANDROID_TOOLS**：ld,gcc,ranlib的路径，用于Setenv-android-input.sh中确定文件存在的作用。
>* **CFLAGS**：
>* **OPTIONS**：
>* **ANDROID_DEV_INCLUDE**：在openssl中Configure中需要用到的头文件包含路径，由于当前ndk版本不同，头文件路径可能不同，包含了多个可能有头文件的路径。
>* **CONFIGURE_COMMAND**：openssl的config命令
>* **LIB_INSTALL_DIR**：输出结果的lib目录。
>* **INCLUDE_INSTALL_DIR**：输出结果的include目录。
>* **OPENSSL_INCLUDE_DIR**：openssl的include目录。用于复制到INCLUDE_INSTALL_DIR。

### 文件Setenv-android-input.sh
* 由于在调用Setenv-android文件比较省事，因此直接调用，但是需要环境变量保留，添加函数say_hello()，作为函数调用。
* 虽然有BUILD_CLANG的判断和环境变量设置，但是由于Clang在openssl中ld会有参数错误，所以仍需要查看原因。
* 按照openssl中所讲，FIPS_SIG报错不用关心。
* 其中主要变量含义如下：
>* **ANDROID_NDK_ROOT**：ndk路径
>* **_ANDROID_EABI**：/ndk-bundle/toolchains下的目录名称，如：x86_64-4.9。
>* **_ANDROID_ARCH**：/ndk-bundle/platforms/android-27下的目录名称，如：arch-x86_64.
>* **_ANDROID_API：如：android-27。
>* **ANDROID_TOOLCHAIN**：执行相关运行程序的目录。如：/ndk-bundle/toolchains/x86_64-4.9/prebuilt/darwin-x86_64/bin
>* **PATH**：很重要，将ANDROID_TOOLCHAIN添加到环境变量PATH，才能直接调用相关的gcc，不然需要设置为绝对路径。
>* **ANDROID_TOOLCHAIN_HOST**：与ndk安装相关，为了之后调用目录。如：darwin-x86_64。
>* **ANDROID_SYSROOT**：如：/ndk-bundle/platforms/android-27/arch-x86_64
>* **CROSS_SYSROOT**：ANDROID_SYSROOT
>* **NDK_SYSROOT**：ANDROID_SYSROOT
>* **MACHINE，RELEASE，SYSTEM，ARCH**：为openssl推荐添加，没有找到用的地方。
>* **CROSS_COMPILE**：前缀，在openssl中的Configure中可以看到调用gcc的名称x86_64-linux-android-gcc。如：x86_64-linux-android-。
>* **ANDROID_DEV**：很重要，在openssl中的Configure中可以看到调用此路径下的lib。如：/ndk-bundle/platforms/android-27/arch-x86_64/usr

### openssl中文件的主要修改
/Configure文件
>* 添加x86_64，mips64，64位的时候(由于在ld的时候报错找不到crtbegin_so.o，需要修改为lib64)，ndk中的目录为lib64:/ndk-bundle/platforms/android-27/arch-mips64/usr/lib64
>* 由于在某一版本之后ndk的include路径修改为sysroot下，因此需要添加环境变量：ANDROID_DEV_INCLUDE，作为include的路径。
>* 添加在脚本中定义的CFLAGS:`\$(CFLAGS)`
>* 关于android相关内容改为如下，注释掉原有的内容：
```
# Android: linux-* but without pointers to headers and libs.
# "android","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# "android-x86","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# "android-armv7","gcc:-march=armv7-a -mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${armv4_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# "android-mips","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${mips32_asm}:o32:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android","gcc: \$(CFLAGS) -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-x86","gcc: \$(CFLAGS) -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-armv7","gcc: \$(CFLAGS) -march=armv7-a -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${armv4_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-mips","gcc: \$(CFLAGS) -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib -O3 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${mips32_asm}:o32:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-x86_64","gcc: \$(CFLAGS) -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib64 -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-mips64","gcc: \$(CFLAGS) -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib64 -O3 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

```

*PS：由于mips64使用asm加速找不到合适的mips64r6，总报错，因此修改为no_asm*

### testJniOpenssl测试demo


### 遇到问题
* 各种基础头文件找不到，如stdlib.h等头文件
**解决方法**：ndk中支持的头文件没找到，可以看到报错的那句中-I的目录是否有问题，如果有问题，则查看Configure文件中的-I后的头文件目录是否正确，如果正确，则看到配置的目录中是否有include目录，如果错误，修改sh中定义的目录，或者Configure中的环境变量，参照当前使用的ANDROID_DEV_INCLUDE。

* openssl支持的架构配置错误
**解决方法**：确定Configure中是否有当前配置的架构

* 在安卓中调用的时候出现如下问题：
```
  FAILED: : && /xxx/android-sdk-macosx/ndk-bundle/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang++  --target=armv7-none-linux-androideabi --gcc-toolchain=/xxx/android-sdk-macosx/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64 --sysroot=/xxx/android-sdk-macosx/ndk-bundle/sysroot -fPIC -isystem /xxx/android-sdk-macosx/ndk-bundle/sysroot/usr/include/arm-linux-androideabi -D__ANDROID_API__=15 -g -DANDROID -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fno-integrated-as -mthumb -Wa,--noexecstack -Wformat -Werror=format-security  -frtti -fexceptions -O0 -fno-limit-debug-info  -Wl,--exclude-libs,libgcc.a -Wl,--exclude-libs,libatomic.a --sysroot /xxx/android-sdk-macosx/ndk-bundle/platforms/android-15/arch-arm -Wl,--build-id -Wl,--warn-shared-textrel -Wl,--fatal-warnings -Wl,--fix-cortex-a8 -Wl,--no-undefined -Wl,-z,noexecstack -Qunused-arguments -Wl,-z,relro -Wl,-z,now -shared -Wl,-soname,libnative-lib.so -o ../../../../build/intermediates/cmake/debug/obj/armeabi-v7a/libnative-lib.so CMakeFiles/native-lib.dir/src/main/cpp/native-lib.cpp.o CMakeFiles/native-lib.dir/src/main/cpp/openssl-jni.c.o  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a ../../../../src/main/jniLibs/armeabi-v7a/lib/libssl.a -ldl -llog -latomic -lm "/xxx/android-sdk-macosx/ndk-bundle/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi-v7a/libgnustl_static.a" && :
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(cryptlib.o):cryptlib.c:function OPENSSL_showfatal: error: undefined reference to 'stderr'
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(cryptlib.o):cryptlib.c:function OPENSSL_stderr: error: undefined reference to 'stderr'
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(ui_openssl.o):ui_openssl.c:function close_console: error: undefined reference to 'stdin'
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(ui_openssl.o):ui_openssl.c:function close_console: error: undefined reference to 'stderr'
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(ui_openssl.o):ui_openssl.c:function read_string_inner: error: undefined reference to 'signal'
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(ui_openssl.o):ui_openssl.c:function read_string_inner: error: undefined reference to 'tcsetattr'
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(ui_openssl.o):ui_openssl.c:function read_string_inner: error: undefined reference to 'tcsetattr'
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(ui_openssl.o):ui_openssl.c:function open_console: error: undefined reference to 'tcgetattr'
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(ui_openssl.o):ui_openssl.c:function open_console: error: undefined reference to 'stdin'
  ../../../../src/main/jniLibs/armeabi-v7a/lib/libcrypto.a(ui_openssl.o):ui_openssl.c:function open_console: error: undefined reference to 'stderr'
  clang++: error: linker command failed with exit code 1 (use -v to see invocation)
  ninja: build stopped: subcommand failed.
```
**原因**：在ndk15+做了一些改变
**解决方法**：在CFLAGS中添加：`-D__ANDROID_API__=$_API`
**参考**：[https://github.com/android-ndk/ndk/issues/445#issuecomment-313322546]（https://github.com/android-ndk/ndk/issues/445#issuecomment-313322546）
**PS**：此方法在我测试时无用（[添加--deprecated-headers，方法无用](https://github.com/openssl/openssl/issues/3826)）,我这编译调用时会报如下错误：
```
usage: make_standalone_toolchain.py [-h] --arch
                                    {arm,arm64,mips,mips64,x86,x86_64}
                                    [--api API]
                                    [--stl {gnustl,libc++,stlport}] [--force]
                                    [-v]
                                    [--package-dir PACKAGE_DIR | --install-dir INSTALL_DIR]
make_standalone_toolchain.py: error: unrecognized arguments: --deprecated-headers
```


* as编译时报错
```
cxx-stl/llvm-libc /include/stdexcept:136: error: undefined reference to 'std::logic_error::logic_error(char const*)'
``` 
**解决方法**：在cmake中的参数添加：`arguments "-DANDROID_STL=c++_static"`
**参考**：[android.mk中的解决方法](https://discuss.cocos2d-x.org/t/errors-when-linking-sdkbox-libraries-with-ndk-r13b-clang-and-c--static-stl/33361/19)
[cmake中的解决方法](https://blog.csdn.net/fpcc/article/details/72820934)

### 待做
* 由于时间问题，目前还有一些冗余的变量，还未精简。
* 现在clang编译还是不通过，需要继续了解。参考：[ics-openvpn中使用的openssl.cmake](https://github.com/schwabe/ics-openvpn/blob/master/main/src/main/cpp/openssl.cmake)这个是Clang可以编译好的，但是需要固定openssl的各个c文件，如果换openssl版本，则需要重新改，不清楚是否有其他方法更方便一些。


