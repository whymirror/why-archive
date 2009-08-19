#!/bin/sh

CC=$1
AC="tools/config.c"
AOUT="tools/config.out"
CCEX="$CC $AC -o $AOUT"

TARGET=`$CC -v 2>&1 | sed -e "/Target:/b" -e "/--target=/b" -e d | sed "s/.* --target=//; s/Target: //; s/ .*//" | head -1`
MINGW_GCC=`echo "$TARGET" | sed "/mingw/!d"`
if [ "$MINGW_GCC" = "" ]; then
  MINGW=0
else
  MINGW=1
fi
JIT_X86=`echo "$TARGET" | sed "/86/!d"`
JIT_PPC=`echo "$TARGET" | sed "/powerpc/!d"`

if [ $MINGW -eq 0 ]; then
  LONG=`echo "#include <stdio.h>
  INT=`echo "#include <stdio.h>
  SHORT=`echo "#include <stdio.h>
  CHAR=`echo "#include <stdio.h>
  LLONG=`echo "#include <stdio.h>
  DOUBLE=`echo "#include <stdio.h>
  LILEND=`echo "#include <stdio.h>
  PAGESIZE=`echo "#include <stdio.h>
  STACKDIR=`echo "#include <stdio.h>
  ARGDIR=`echo "#include <stdio.h>
else
  # hard coded win32 values
  CHAR="1"
  SHORT="2"
  LONG="4"
  INT="4"
  DOUBLE="8"
  LLONG="8"
  LILEND="1"
  PAGESIZE="4096"
  STACKDIR="-1"
  ARGDIR="1"
fi

if [ "$2" = "mingw" ]; then
  if [ $MINGW -eq 0 ]; then
    echo "0"
  else
    echo "1"
  fi
elif [ "$2" = "version" ]; then
  cat core/potion.h | sed "/POTION_VERSION/!d; s/\\\"$//; s/.*\\\"//"
elif [ "$2" = "strip" ]; then
  if [ $MINGW -eq 0 ]; then
    echo "strip -x"
  else
    echo "ls"
  fi
else
  if [ "$JIT_X86$MINGW_GCC" != "" ]; then
    echo "#define POTION_JIT_TARGET POTION_X86"
  elif [ "$JIT_PPC" != "" ]; then
    echo "#define POTION_JIT_TARGET POTION_PPC"
  fi
  echo "#define POTION_PLATFORM \"$TARGET\""
  echo "#define POTION_WIN32    $MINGW"
  echo
  echo "#define PN_SIZE_T     $LONG"
  echo "#define LONG_SIZE_T   $LONG"
  echo "#define DOUBLE_SIZE_T $DOUBLE"
  echo "#define INT_SIZE_T    $INT"
  echo "#define SHORT_SIZE_T  $SHORT"
  echo "#define CHAR_SIZE_T   $CHAR"
  echo "#define LONGLONG_SIZE_T   $LLONG"
  echo "#define PN_LITTLE_ENDIAN  $LILEND"
  echo "#define POTION_PAGESIZE   $PAGESIZE"
  echo "#define POTION_STACK_DIR  $STACKDIR"
  echo "#define POTION_ARGS_DIR   $ARGDIR"
fi