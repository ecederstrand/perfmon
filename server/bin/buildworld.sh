# Optimization suggestion: make -j `sysctl -n hw.ncpu+1` blablabla

cd $SRCDIR
log "Building world"
if MAKEOBJDIRPREFIX="$OBJDIR" make __MAKE_CONF="$MAKECONF" SRCCONF="$SRCCONF" \
      CC=$CC CXX=$CXX TARGET=$TARGET TARGET_ARCH=$TARGET_ARCH buildworld \
      > "$LOGDIR/buildworld-$BUILD_ID.log" 2>&1; then
   log "Successfully built world (using ccache)"
else
   log "buildworld failed (using ccache)" 1
   if tail -n 100 "$LOGDIR/buildworld-$BUILD_ID.log" | grep "Signal 11"; then
      log "buildworld failed due to internal compiler error (\"Signal 11\").\nMost likely, you have faulty hardware, e.g. bad RAM." 3
      exit 1
   elif tail -n 100 "$LOGDIR/buildworld-$BUILD_ID.log" | grep "Error code 127"; then
      log "buildworld failed due to \"Error code 127\".\nMost likely, you have a problem with time on your machine.\nTry syncing time and removing $OBJDIR." 3
      exit 1
   elif MAKEOBJDIRPREFIX="$OBJDIR" make __MAKE_CONF="$MAKECONF" SRCCONF="$SRCCONF" \
         TARGET=$TARGET TARGET_ARCH=$TARGET_ARCH buildworld \
         > "$LOGDIR/buildworld-noccache-$BUILD_ID.log" 2>&1; then
      log "Successfully built world (no ccache)"
   else
      log "buildworld failed (no ccache)" 1
      log "Skipping this build. Waiting $SLEEP seconds.\nSee $LOGDIR/buildworld-$BUILD_ID.log and $LOGDIR/buildworld-noccache-$BUILD_ID.log for details.\n\n" 1
      skip=1
   fi  
fi

