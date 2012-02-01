#!/bin/sh

# Inflates a directory which has been compacted by bsdiff.
#
# This has only been tested with directories containing files, symlinks and
# regular files.
#
# Use: inflate.sh /full/path/to/2007.02.03.04.00.00

BASE=$(dirname $1)
DATE=$(basename $1)

MASTER=`date -jf "%C%y.%m.%d.%H.%M.%S" $DATE "+$BASE/%C%y.%m-master/full"`
TARGET="$BASE/$DATE/compressed"

[ ! -d "$MASTER" ] && echo "$MASTER is not a directory" && exit
[ ! -d "$TARGET" ] && echo "$MASTER is not a directory" && exit

echo "Creating $TARGET/full.tgz"

cd $BASE
cp -R compressed full
cd full

# Restore all files ending with .bsdiff. This will break if a real file ends 
# in .bsdiff.
for patch in `find ./ -type f -name "*.bsdiff"`
do
    orig=`echo $patch | sed 's/.bsdiff//'`
    echo "Patching $orig"
    bspatch $MASTER/$orig $orig $patch
    rm $patch
done

# Restore permissions, ownership etc. XXX What about hardlinks? Let's hope 
# permissions haven't changed between MASTER and TARGET.
echo "Restoring ownership, permissions and flags"
mtree -Uf ../full.mtree
tar -czf ../full.tgz
chflags -R noschg *
cd ..
rm -r full

echo "Done"
