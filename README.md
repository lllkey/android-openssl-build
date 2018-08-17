# android-openssl-build
ndk编译openssl，"armeabi-v7a" "arm64-v8a" "x86" "x86_64" "mip" "mip_64"

## 运行方法
* 1 按照本地ndk和openssl路径修改compile-openssl-android.sh中相关定义
> _ANDROID_NDK_ROOT：ndk绝对路径
> _OPENSSL_GCC_VERSION：gcc版本号：从ndk绝对路径/toolchains中看后面的版本号
> _ANDROID_API：从ndk绝对路径/platforms中找到合适的安卓的版本
> _OPENSSL_ROOT：openssl的绝对路径
> _INSTALL_ROOT：生成的文件的绝对路径
* 2 运行compile-openssl-android.sh文件
`./compile-openssl-android.sh`

## 主要工作


### openssl中文件的主要修改
Configure文件，由于在某一版本之后ndk的include路径修改为sysroot下，因此需要添加环境变量：ANDROID_DEV_INCLUDE，作为include的路径。关于android相关内容改为如下，注释掉原有的内容：
```
# Android: linux-* but without pointers to headers and libs.
# "android","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# "android-x86","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# "android-armv7","gcc:-march=armv7-a -mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${armv4_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# "android-mips","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${mips32_asm}:o32:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android","gcc: -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-x86","gcc: -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-armv7","gcc:-march=armv7-a -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${armv4_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-mips","gcc: -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib -O3 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${mips32_asm}:o32:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-x86_64","gcc: -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib64 -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"android-mips64","gcc: -I\$(ANDROID_DEV_INCLUDE) -B\$(ANDROID_DEV)/lib64 -O3 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
```

*PS：由于mips64使用asm加速找不到合适的mips64r6，总报错，因此修改为no_asm*

### 待做
* clang编译还是不通过，需要继续了解

