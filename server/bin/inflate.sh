#!/bin/sh

# Inflates a directory which has been compacted by bsdiff.
#
# This has only been tested with directories containing files, symlinks and
# regular files.
#
# Use: inflate.sh /full/path/to/branch/revision

REVDIR=$1
[ ! -d "$REVDIR" ] && echo "$REVDIR is not a directory" && exit
[ ! -d "$REVDIR/compressed" ] && echo "$REVDIR/compressed is not a directory" && exit

BRANCHDIR=$(dirname $REVDIR)
REV=$(basename $REVDIR)
REV_NUMBER=`echo '$REV' | sed 's/r//'`
MASTERREV=`bc -e '$REV_NUMBER / 1000 * 1000' -e quit`

MASTERDIR="$BRANCHDIR/r$MASTERREV-master"
[ ! -d "$MASTERDIR" ] && echo "$MASTERDIR is not a directory" && exit

echo "Creating $TARGETDIR/full.tgz"

cd "$REVDIR"
cp -R compressed full
cd full

# Restore all files ending with .bsdiff. This will break if a real file ends 
# in .bsdiff.
for patch in `find ./ -type f -name "*.bsdiff"`
do
    orig=`echo $patch | sed 's/.bsdiff//'`
    echo "Patching $orig"
    bspatch $MASTERDIR/$orig $orig $patch
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
