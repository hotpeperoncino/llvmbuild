#!/bin/bash -x
# SYNTAX ARGV: 1: 40 or 70, 2: release or debug, 3: PROJECTNAME, 4: test(none)

PROJECTNAME=$3
TEST=$4
WSROOT=`pwd`/llvm

cd $WSROOT
#!/bin/sh -xe

export V=$1
export ROOT=$WSROOT
export TMPSRC=$ROOT/llvm$V
export DISKSRC=$ROOT/llvm$V
export SRC=$DISKSRC/src
export DEST=$ROOT/llvm$V/dest
export BUILD=$DISKSRC/build

export TYPE=Release
if [ x$2 = "xdebug" ]; then
    export TYPE=Debug
fi

if [ x$1 = x"40" ]; then
    RELEASE=tags/RELEASE_401/final
else
    RELEASE=tags/RELEASE_700/final
fi

# mkdir -p $RAMDIR
# ln -s $RAMDISKSRC $DISKSRC
# ln -s $RAMDIR $RAMDISKSRC

mkdir -p $ROOT
mkdir -p $DISKSRC
mkdir -p $SRC
mkdir -p $DEST
mkdir -p $BUILD/llvm-build

cd $SRC
svn co http://llvm.org/svn/llvm-project/llvm/$RELEASE llvm
cd $SRC/llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/$RELEASE clang
#svn co http://llvm.org/svn/llvm-project/ldd/$RELEASE ldd
#svn co http://llvm.org/svn/llvm-project/lldb/$RELEASE lldb

cd $SRC/llvm/projects
svn co http://llvm.org/svn/llvm-project/compiler-rt/$RELEASE compiler-rt
svn co http://llvm.org/svn/llvm-project/openmp/$RELEASE openmp
svn co http://llvm.org/svn/llvm-project/polly/$RELEASE polly
svn co http://llvm.org/svn/llvm-project/lld/$RELEASE lld
svn co http://llvm.org/svn/llvm-project/libunwind/$RELEASE lld
#svn co http://llvm.org/svn/llvm-project/libcxx/$RELEASE libcxx
#svn co http://llvm.org/svn/llvm-project/libcxxabi/$RELEASE libcxxabi
if [ x$TEST = "none" ]; then
CMAKETESTOPT=
else
 #svn co http://llvm.org/svn/llvm-project/test-suite/trunk llvm-test
 #CMAKETESTOPT=-DLLVM_BUILD_TESTS=1
 #CMAKETESTOPT=-DLLVM_BUILD_TESTS=1
echo "here"
fi

cd $BUILD/llvm-build
cmake -G "Unix Makefiles" $SRC/llvm -DCMAKE_INSTALL_PREFIX=$DEST -DCMAKE_BUILD_TYPE=$TYPE -DLLVM_ENABLE_RTTI=TRUE -DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_BUILD_DOCS=OFF -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_BUILD_TEST=ON $CMAKETESTOPT

#./configure --enable-debug-symbols --prefix=$DEST --build=x86_64-linux-gnu
make -j4
make install

