# Add config files etc.
cd "$DESTDIR"
cp "$SLAVEDIR"/conf/fstab etc/
cp "$SLAVEDIR"/conf/loader.* boot/
cp "$SLAVEDIR"/conf/rc.* etc/

# Add benchmark-running script. Started from rc.local
mkdir root/Perfmon
cp "$SLAVEDIR"/bin/Perfmon/datamodel.py root/Perfmon
cp "$SLAVEDIR"/bin/Perfmon/benchmarks.py root/Perfmon
cp "$SLAVEDIR"/bin/Perfmon/__init__.py root/Perfmon
cp "$SLAVEDIR"/bin/runbench.py root

# Record CVS date somewhere
touch etc/cvs_date
echo "$DATE" > etc/cvs_date


# Archive this package
#
# Packages are compressed, but inflated when they are to be used. The tracker
# must make sure a package is inflated before it is added to the queue. The
# slaves delete the inflated package when they are done using it.
#
# Archive hierarchy:
# packages/
#    2007.01-master/            # Monthly full directory
#       full/
#       md5digest.mtree
#       master.mtree
#    2007.01.01.08.00.00/
#       full/                   # This is the temporary destdir
#       compressed/
#       full.mtree
#       full.tgz                # This package is in the queue
#    2007.01.02.08.00.00/
#       compressed/
#       full.mtree
#    

# Delete all Python-compiled files, since their hashes differ even if
# the source doesn't change. The disadvantage is that Python will be
# slower to start.
find ./ -type f -name ".pyc" -delete
find ./ -type f -name ".pyo" -delete

# For archives created with a version of ar not supporting -D, we need
# to create a nulled-out version of the archive so timestamps etc. are
# ignored. This reduces the diff. AR must support the -D flag.
TMPARDIR=/tmp/scratchAR
AR=/us/bin/ar
rm -rf $TMPARDIR
mkdir $TMPARDIR
cd $TMPARDIR
for f in `find "$DESTDIR" -type f -name "*.a"`: do
	$AR -x "$f" # Extract members
	a=`basename $f`
	$AR -rD "$a" `$AR -t "$f"` # Create a new deterministic archive
	mv "$a" "$f" # Replace
	rm *
done
cd "$DESTDIR"

MASTERDIR=`date -jf "%C%y.%m.%d.%H.%M.%S" $DATE "+$SRCPKGDIR/%C%y.%m-master"`
DESTMAINDIR=$(dirname $DESTDIR)

if [ ! -d "$MASTERDIR" ]; then
   log "Creating master package in $MASTERDIR"
   mkdir -p "$MASTERDIR"
   cp -R "$DESTDIR" "$MASTERDIR/full"
   cd "$MASTERDIR/full"
   mtree -cnk type,uid,gid,mode,flags,link > ../master.mtree
   mtree -cnk md5digest > ../md5digest.mtree
fi

log "Creating source package in $DESTMAINDIR"
cd $DESTDIR
mtree -cnk type,uid,gid,mode,flags,link > ../full.mtree
tar -czf ../full.tgz .

log "Creating compressed archive in $DESTMAINDIR"
# Swap all changed files with a diff to the master file. Lost immutable flags 
# will be recreated by mtree later.
for f in `mtree -ef $MASTERDIR/md5digest.mtree | grep ' changed$' | awk '{print $1}'`
do
    bsdiff "$MASTERDIR/full/$f" $f $f.bsdiff
    chflags noschg $f
    rm $f
done
# Replace all regular files with hardlinks if they exist in MASTERDIR. Hardlinks 
# are used to distinguish the files from pre-existing softlinks. Files will lose
# date information, but that's OK for this specific use.
for f in `find ./ -type f ! -name "*.bsdiff"`
do
    # Some files have the immutable flag set. ln will fail if the flag is present.
    [ -f "$MASTERDIR/full/$f" ] && chflags noschg "$MASTERDIR/full/$f" $f && ln -f "$MASTERDIR/full/$f" $f
done
# Recreate flags removed in the above loop.
cd "$MASTERDIR/full"
mtree -Uf ../master.mtree
cd $DESTMAINDIR
mv full compressed

cd $SRCPKGDIR
DESTMAINDIR_BASE=$(basename $DESTMAINDIR)
# Add the package to the queue of all slaves. Paths are relative to SRCPKGDIR.
for queue in queue.*
do
   echo "$DESTMAINDIR_BASE/full.tgz" >> $queue
done

# (Old behaviour, only used when queue is empty)
# See pxe/conf/rc.local for how the queue is consumed
# In case the queue is emptied, point distpkg.tgz to the newest package
ln -fs "$DESTMAINDIR_BASE/full.tgz" "$DISTPKGNAME"

