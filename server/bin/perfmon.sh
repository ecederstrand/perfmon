#!/bin/sh

#
# Please read doc/README.txt for information on using this script.
# All configuration is done in conf/perfmon.conf
#

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

DIRNAME=$(dirname $0) # Temp variable for importing conf files

. "$DIRNAME/common.sh"  # Pull in common functions

. "$DIRNAME/../conf/defaults/perfmon.conf"
if [ -r "$DIRNAME/../conf/perfmon.conf" ]; then
   . "$DIRNAME/../conf/perfmon.conf"
else
   log "$DIRNAME/../conf/perfmon.conf not found. You can use perfmon.conf.sample as template." 3
	exit 1
fi

# Check if a process is already running
if [ -r "$PIDFILE" ] ; then
  # A lock file already exists
  if [ "$(ps -p `cat $PIDFILE` | wc -l)" -gt 1 ]; then
    # Old process is still running
    log "An instance is already running with PID `cat $PIDFILE`" 3
    exit 1
  else
    # Process not running, but lock file not deleted
    log "Stale lock file deleted." 1
    rm "$PIDFILE"
  fi
fi

# Create lock file
echo $$ > "$PIDFILE"


# Handle SIGHUP/INT/TERM and at least somewhat cleanly shut down
# Unmount /proc, /dev and /usr/ports  within the source package dir (if we were installing ports)
# Delete incomplete source package folders (if we were installing base or ports)
# Remove process lock
trap "echo 'Aborting';
      umount `mount | awk '{print $3}' | grep $SRCPKGDIR` >/dev/null 2>&1;
      chflags -R noschg $SRCPKGDIR/$BRANCH* >/dev/null 2>&1;
      rm -r $SRCPKGDIR/$BRANCH* >/dev/null 2>&1;
      rm $PIDFILE;
      exit 1"  1 2 15

SCRIPT_NAME=$(basename $0)
# Parse command line options
ALLLOGS=0       # If set to 1, save all log files, not just error logs
CLEAN=0         # If set, check out new working copies of the src/ports repos
LOOP=0          # The script can loop forever, or run once

while getopts acd:e:i:l OPTION
do
    case $OPTION in
        a) ALLLOGS=1;;
        c) CLEAN=1;;
        r) CMD_REV="$OPTARG";;
        e) EMAIL="$OPTARG";;
        n) INTERVAL="$OPTARG";;
        l) LOOP=1;;
       \?) echo "usage: ${SCRIPT_NAME} [ -acl ] [ -d YYYY.MM.DD.HH.mm.ss [ -i interval ] ]
       -a: Save all log files. If unset, only save error logs.
       -c: Delete local working copies of the src and ports and check out new ones.
       -e: Send notice to this email address when the build has completed (or failed).
       -l: Run forever. If unset, only run once.
       -r: SVN revision to update sources to. If unset, update to HEAD.
       -n: Number of SVN revisions to increase the current revision with on the next iteration. If unset, update to HEAD"
           exit 1;;
    esac
done

# Check if we are root
if [ ! `whoami` = "root" ]; then
   log "You need to run this script as root." 3
   exit 1
fi

# Check if dependent programs are installed
if [ ! -x "/usr/local/bin/ccache" ]; then
   log "You need to install devel/ccache." 3
   exit 1
fi
if [ ! -x "/usr/local/bin/fastest_cvsup" ]; then
   log "You need to install sysutils/fastest_cvsup." 3
   exit 1
fi
if [ ! -x "/usr/local/bin/svn" ]; then
   log "You need to install devel/subversion." 3
   exit 1
fi

# Check existence of ports config file
if [ ! -r "$SLAVEDIR/ports/portlist.conf" ]; then
   log "$SLAVEDIR/ports/portlist.conf not found." 3
   exit 1
fi

# Write info
log "Starting PerfMon script."
if [ "$LOOP" = "0" ]; then
   log "The script will run once."
else
   log "The script will run forever, or until Ctrl-C."
fi
if [ -n "$CMD_REV" ]; then
   log "The first run will use SVN revision $CMD_REV\n\n"
else
   log "The script will update to current sources and run from there.\n\n"
fi
if [ -n "$INTERVAL" ]; then
   log "The script will move forward $INTERVAL revisions on every run.\n\n"
fi

if [ ! -d "$SVNMIRROR/hooks" ]; then
   log "You don't seem to have a local SVN mirror in $SVNMIRROR. Please create one, as detailed in http://wiki.freebsd.org/SubversionPrimer#Setting_up_a_svnsync_mirror." 3
   exit 1
fi

if [ "$CLEAN" -eq "1" ]; then
   # Wipe out working directory and check out a clean version from the local CVS repo
   log "Wiping out working copy and checking out new version"
   rm -r "$SRCDIR" "$PORTSDIR"

   cd "$WORKDIR"
   svn co "file://$SVNMIRROR/$BRANCH" "$SRCDIR" > /dev/null
   fi
   cvs -q -d "$SUPBASE" checkout -P ports > /dev/null
else
   if [ ! -r "$SRCDIR/ObsoleteFiles.inc" ]; then
      log "You don't seem to have a local working copy in $SRCDIR. Use the -c option to create one." 3
      exit 1
   fi
   log "Using current working copy of the src/ports repos"
fi

# ccache setup
unset CCACHE_PATH
mkdir -p $CCACHE_DIR
export CCACHE_DIR=$CCACHE_DIR
ccache -M $CCACHE_MAXSIZE > /dev/null


# Main loop
# Loop forever, or until Ctrl-C
# Run only once if looping is not specified on the command line
while [ "$LOOP" != "0" ]
do
    skip=0 # Flag to indicate errors along the road


    # Part 0: Check available disk space in slave package and log dirs. This 
    # is where most data will accumulate
    # Disk space in MB's
    diskspace=`df -m $SRCPKGDIR | grep /dev | awk '{print $4}'`
    if [ "$diskspace" -lt "600" ]; then
       log "The disk space in $SRCPKGDIR is critically low. $diskspace MB left." 3
       exit 1
    fi
    diskspace=`df -m $LOGDIR | grep /dev | awk '{print $4}'`
    if [ "$diskspace" -lt "100" ]; then
       log "The disk space in $LOGDIR is critically low. $diskspace MB left." 3
       exit 1
    fi


    # Part 1: Get the latest (or requested) src and ports sources.
    # This populates or updates work/.
    . $BINDIR/update.sh


    # Part 2: Build world.
    # This populates work/obj.
    [ "$skip" -ne "1" ] && . $BINDIR/buildworld.sh


    # Part 3: Build kernels.
    # This further populates work/obj.
    [ "$skip" -ne "1" ] && . $BINDIR/buildkernel.sh


    # Part 4: Install files to a temp directory
    [ "$skip" -ne "1" ] && . $BINDIR/install.sh


    # Part 5: Install ports into the temp directory
    [ "$skip" -ne "1" ] && . $BINDIR/ports.sh


    # Part 6: tar/zip the folder and make this the new default source package
    [ "$skip" -ne "1" ] && . $BINDIR/package.sh


    # Clean up if some of the ports failed to install
    if [ "$skip" -eq "1" ]; then
       if [ -d "$DESTDIR" ]; then
          # Clean up
          cd "$SRCPKGDIR"
          chflags -R noschg "$DESTDIR"
          rm -r "$DESTDIR"
          sleep $SLEEP
          continue
       fi
    fi

    # Notify the supplied email address
    if [ -n "$EMAIL" ]; then
        if [ "$skip" -eq "1" ]; then
            msg="I'm sorry. Your build failed. Attached are the relevant logs."
            logs=`tail -n 20 $LOGDIR/*$BUILD_ID.log`
            msg="$msg
    $logs"
        else
            msg="Your build ($BRANCH $REV) was successfully built and queued for processing.\n\n"
            # Calculate worst-case time before results are ready,
            # assuming a slave run takes 2 hours
            h=`wc -l $SRCPKGDIR/queue.* | sort -r | head -n 1 | awk '{print $1}'`
            h=$(expr $h "*" 2 + 4)
            msg="$msg

    Your performance data should be processed and accessible within $h hours."
        fi
        echo "$msg" | mail -s "Message from PerfMon" $EMAIL
    fi

    # If requested, remove all logs from this run. All logs are saved if an error occurred.
    if [ "$ALLLOGS" -eq "0" ]; then
       [ "$skip" -ne "1" ] && rm "$LOGDIR"/*$BUILD_ID.log
    fi

    # Write status
    log "This run is finished.\n\n"

# End of main loop
done

# Never reached when looping
rm $PIDFILE
echo "Done"
exit 0
