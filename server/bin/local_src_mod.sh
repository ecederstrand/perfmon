#!/bin/sh

# This file contains any local source code modifications needed before compiling
# sources and ports. Working copies are located in $SRCDIR and $PORTSDIR.
#
# Example use includes removing debugging options in malloc on HEAD or trying 
# out experimental patches.
#
# This file is sourced by update.sh. Changes are reverted (by 'cvs update -C') 
# on every loop, so this script must be run after every source code update.


# destdir_sufffix="_mylocalmod"	# If defined, this variable is used to suffix packages
				# in the archive, so "sideways" compiles don't overwrite
				# each other.


# sed -i 's/.*define.*MALLOC_PRODUCTION.*/#define MALLOC_PRODUCTION/' $SRCDIR/lib/libc/stdlib/malloc.c
