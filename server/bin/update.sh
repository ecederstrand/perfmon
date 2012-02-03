# Get the current SVN REV
# If a revision is specified from the command-line, use this value in the first run
if [ -n "$CMD_REV" ]; then
   REV="$CMD_REV"
   unset CMD_REV # Avoid using the specified date again
elif [ -n "$INTERVAL" ]; then
   # Only in combination with CMD_REV. Increase $REV with the specified interval
   REV=`bc -e '$REV + $INTERVAL' -e quit`
else
   # Get the most up-to-date revision
   REV='HEAD'
fi

# Update sources from local CVS repo. Operate on UTC dates. Attempt to delete local modifications.
log "Updating ports and $BRANCH sources in the work directory as of CVS date $DATE (UTC)"
cd "$SRCDIR"
svn up -r $REV > "$LOGDIR/svn-update-src-$BRANCH_r$REV.log" 2>&1
cd "$PORTSDIR"
cvs -qd $SUPBASE update -D "$DATE UTC" -PCd > "$LOGDIR/cvs-update-ports_$DATE.log" 2>&1


# Copy kernel config file to the right place
if [ ! -r "$SRCDIR/sys/$TARGET_ARCH/conf/$KERNEL" ]; then
   cp "$SLAVEDIR/conf/$KERNEL" "$SRCDIR/sys/$TARGET_ARCH/conf/$KERNEL"
fi

# Perform any local modifications to the source code
. $SERVERDIR/bin/local_src_mod.sh

# Unique strings for logging and archiving. $destdir_prefix comes from local_src_mod.sh. If 
# this script is unused, the var will be empty

BRANCH_ID="destdir_prefix$BRANCH$"
BUILD_ID="$BRANCH_ID-r$REV"
