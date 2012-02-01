# Get the current UTC date in CVS format
# If a date is specified from the command-line, use this value in the first run
if [ -n "$CMD_DATE" ]; then
   DATE="$CMD_DATE"
   unset CMD_DATE # Avoid using the specified date again
elif [ -n "$INTERVAL" ]; then
   # Only in combination with CMD_DATE. Alter $DATE with the specified interval
   DATE=`date -jf "%C%y.%m.%d.%H.%M.%S" -v $INTERVAL $DATE "+%C%y.%m.%d.%H.%M.%S"`
else
   # Get current date in UTC, subtracting a delay to give cvsup servers time to sync
   DATE=`date -ju -v $DELAY "+%C%y.%m.%d.%H.%M.%S"`
fi
now=`date -ju -v $DELAY "+%C%y%m%d%H%M%S"`
if [ `echo $DATE | sed s/\\\.//g` -gt "$now" ]; then
   DATE=`date -ju -v $DELAY "+%C%y.%m.%d.%H.%M.%S"`
   log "You are trying to update sources to a date in the future." 1
   log "Setting date to the latest possible ($DATE)." 1
fi

# Sanity check DATE (check for dddd.dd.dd.dd.dd.dd format)
if ! echo $DATE | grep '[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}' > /dev/null; then
   log "This is not a CVS date: $DATE" 3
   exit 1
fi

# Check if cvsup has been run on local CVS repo since the date we wish to update to.
# The check assumes that cvsup is never run on the repo with the date option, and that 
# cvsup was allowed to finish updating.
repo_epoch=`stat -f "%m" $SUPBASE/sup/src-all/checkouts.cvs`     # Epoch time
repo_date=`date -ju -v $DELAY -r $repo_epoch "+%C%y%m%d%H%M%S"`  # Convert to CVS date format and subtract 
                                                                 # a time delay to account for cvsup server 
                                                                 # sync time

if [ `echo $DATE | sed s/\\\.//g` -gt "$repo_date" ]; then
   # We're trying to update the working copy to a date newer than what the local CVS repo
   # has, so we need to update the local CVS repo first.

   # Add the prefix to the cvsup file
   # The prefix defaults to base dir, so there is no reason to specify it
   #sed "s|default prefix=.*|default prefix=$SUPPREFIX|" "$SUPFILE" > "$SUPFILE.tmp"
   log "Determining fastest cvsup server"
   CSUPHOST=`fastest_cvsup -c $LOCALTLDS -Q`
   log "Updating local CVS repo from $CSUPHOST"
   # The -s option makes cvsup faster, but is dangerous if the 
   # local tree is ever modified. The option is unused for now.
   if cvsup -r 5 -h "$CSUPHOST" -b "$SUPBASE" "$SUPFILE" > "$LOGDIR/cvsup-$DATE.log" 2>&1; then
      log "Successfully got sources and ports from $CSUPHOST"
      if ! grep "src/" "$LOGDIR/cvsup-$DATE.log" > /dev/null 2>&1; then
         # We assume that the src has been compiled already at some point.
         # Sleeping here allows us to pause in the case that build errors occur on this
         # specific version. Otherwise we risk bombarding the cvsup servers with update
         # requests. We only need to pause here in the "bleeding edge" case, since in all 
         # other situations where we wish to skip the build (historical versions), we can 
         # just continue with the next scheduled date by pulling in the correct version from
         # the local CVS repo.
         log "No updates to src in the local CVS repo. Waiting $SLEEP seconds.\n\n"
         skip=1
         sleep $SLEEP
      fi
      # Clean up
      [ "$ALLLOGS" -eq "0" ] && rm "$LOGDIR"/*$DATE.log
   else
      # Take a deep breath and hope this is just a temporary problem
      log "Could not contact $CSUPHOST. Waiting $SLEEP seconds.\n\n" 1
      skip=1
      sleep $SLEEP
   fi
   #rm "$SUPFILE.tmp"
else
   repo_date_cvs=`date -ju -r $repo_epoch "+%C%y.%m.%d.%H.%M.%S"`
   log "The local CVS repo is sufficiently up-to-date ($repo_date_cvs). No cvsup needed."
fi

# Update sources from local CVS repo. Operate on UTC dates. Attempt to delete local modifications.
log "Updating ports and $BRANCH sources in the work directory as of CVS date $DATE (UTC)"
cd "$SRCDIR"
cvs -qd $SUPBASE update -D "$DATE UTC" -PCd > "$LOGDIR/cvs-update-src-$DATE.log" 2>&1
cd "$PORTSDIR"
cvs -qd $SUPBASE update -D "$DATE UTC" -PCd > "$LOGDIR/cvs-update-ports-$DATE.log" 2>&1


# Copy kernel config file to the right place
if [ ! -r "$SRCDIR/sys/$TARGET_ARCH/conf/$KERNEL" ]; then
   cp "$SLAVEDIR/conf/PERFMON" "$SRCDIR/sys/$TARGET_ARCH/conf/$KERNEL"
fi

# Perform any local modifications to the source code
. $SERVERDIR/bin/local_src_mod.sh
