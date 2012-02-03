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

# Record SVN revision somewhere
touch etc/cvs_date
echo "$BUILD_ID" > etc/perfmon_build_id


# Archive this package
#
# Packages are compressed, but inflated when they are to be used. The tracker
# must make sure a package is inflated before it is added to the queue. The
# slaves delete the inflated package when they are done using it.
#
# Archive hierarchy:
# packages/
#    r123000-master/            # Full directory every 1000 revs
#       full/
#       md5digest.mtree
#       master.mtree
#    r123456/
#       full/                   # This is the temporary destdir
#       compressed/
#       full.mtree
#       full.tgz                # This package is in the queue
#    r123457/
#       compressed/
#       full.mtree
#    

# Delete all Python-compiled files, since their hashes differ even if
# the source doesn't change. The disadvantage is that Python will be
# slower to start.
find ./ -type f -name ".pyc" -delete
find ./ -type f -name ".pyo" -delete

MASTERREV=`bc -e '$REV / 1000 * 1000' -e quit`
MASTERDIR="$BRANCHDIR/r$MASTERREV-master"

if [ ! -d "$MASTERDIR" ]; then
   log "Creating master package in $MASTERDIR"
   mkdir -p "$MASTERDIR"
   cp -R "$DESTDIR" "$MASTERDIR/full"
   cd "$MASTERDIR/full"
   mtree -cnk type,uid,gid,mode,flags,link > ../master.mtree
   mtree -cnk md5digest > ../md5digest.mtree
fi

log "Creating source package in $REVDIR"
cd "$DESTDIR"
mtree -cnk type,uid,gid,mode,flags,link > ../full.mtree
tar -czf ../full.tgz .

log "Creating compressed archive in $REVDIR"
# Swap all changed files with a diff to the master file. Lost immutable flags 
# will be recreated by mtree later.
for f in `mtree -ef $MASTERDIR/md5digest.mtree | grep ' changed$' | awk '{print $1}'`
do
    bsdiff "$MASTERDIR/full/$f" "$f" "$f.bsdiff"
    chflags noschg "$f"
    rm "$f"
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
cd "$REVDIR"
mv full compressed

cd "$SRCPKGDIR"
# Add the package to the queue of all slaves. Paths are relative to SRCPKGDIR.
for queue in queue.*
do
   echo "$REVDIR/full.tgz" >> $queue
done

# (Old behaviour, only used when queue is empty)
# See pxe/conf/rc.local for how the queue is consumed
# In case the queue is emptied, point distpkg.tgz to the newest package
ln -fs "$REVDIR/full.tgz" "$DEFAULTDISTPKG"

