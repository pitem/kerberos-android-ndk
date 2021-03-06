#! /bin/bash

#
# Program : android-configure.sh
# Author  : Chris Conlon, wolfSSL (www.wolfssl.com)
#
# Date    : February 15, 2012
#
# Description: This script will configure the MIT Kerberos library
#              for cross-compilation by the Android NDK stand-
#              alone toolchain.
#
# Instructions:
#   1) Download, install, and set up the Android SDK and Android NDK 
#      standalone toolchain.
#           SDK:  http://developer.android.com/sdk/index.html
#           NDK:  http://developer.android.com/sdk/ndk/index.html
#   2) Place this script in the /src directory of the kerberos
#      source directory.
#   3) Run ./autoconf if needed
#   4) Run ./android-configure.sh
#   5) Exclude the following directories by removing or renaming them.
#      NOTE: This script does this automatically.
#           mv ./clients ./clients.exclude   [ kerberos clients ]
#           mv ./tests ./tests.exclude       [ kerberos tests ]
#           mv ./appl ./appl.exclude         [ kerberos applications ]
#           mv ./kadmin ./kadmin.exclude     [ kadmin ]
#   6) Run make
#   7) Install in desired location:
#           make DESTDIR=<staging/path/here> install
#   8) Copy built libraries from staging location to desired 
#      Android project.
#

## Add Android NDK Cross Compile toolchain to path
export PATH=/Users/chrisc/android/toolchains/android-9-toolchain/bin:$PATH

## Set up variables to point to Cross-Compile tools
export CCBIN="/Users/chrisc/android/toolchains/android-9-toolchain/bin"
export CCTOOL="$CCBIN/arm-linux-androideabi-"

## Export our ARM/Android NDK Cross-Compile tools
export CC="${CCTOOL}gcc"
export RANLIB="${CCTOOL}ranlib"
export AR="${CCTOOL}ar"

## Point these to your cross-compiled CyaSSL library location. CyaSSL can be
## built for Android using the cyassl-android-ndk package or by
## cross-compiling it for Android using wolfSSL's shell script (www.wolfssl.com)
## and the Android NDK Standalone toolchain.
export CYASSL_LIB="/Users/chrisc/android/projects/cyassl-android-ndk/obj/local/armeabi"
export CYASSL_INC="/Users/chrisc/android/projects/cyassl-android-ndk/jni/cyassl/include"
export LDFLAGS="-L$CYASSL_LIB -lm"
export CFLAGS="-I$CYASSL_INC -DANDROID"

## Configure the library
ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes krb5_cv_attr_constructor_destructor=yes ac_cv_func_regcomp=yes ac_cv_printf_positional=no ./configure --target=arm-linux-androideabi --host=arm-linux-androideabi --enable-static --disable-shared --with-crypto-impl=cyassl --with-prng-alg=os

## Adjust autoconf.h's KRB5_DNS_LOOKUP definition
#unamestr = `uname`
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
    sed -i 's/#define KRB5_DNS_LOOKUP 1/#undef KRB5_DNS_LOOKUP/g' include/autoconf.h
elif [[ $unamestr == 'Darwin' ]]; then
    sed -i '' 's/#define KRB5_DNS_LOOKUP 1/#undef KRB5_DNS_LOOKUP/g' include/autoconf.h
fi

##  Skip building the parts we don't need. After running ./configure, if a 
##  folder is renamed or deleted, it will be skipped during the build process.
if [ -d "./appl" ]; then
    mv ./appl ./appl.exclude
    echo "Renamed ./appl to ./appl.exclude"
fi
if [ -d "./clients" ]; then
    mv ./clients ./clients.exclude
    echo "Renamed ./clients to ./clients.exclude"
fi
if [ -d "./tests" ]; then
    mv ./tests ./tests.exclude
    echo "Renamed ./tests to ./tests.exclude"
fi
if [ -d "./kadmin" ]; then
    mv ./kadmin ./kadmin.exclude
    echo "Renamed ./kadmin to ./kadmin.exclude"
fi

