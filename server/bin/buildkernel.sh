log "Building kernels"
if MAKEOBJDIRPREFIX="$OBJDIR" make __MAKE_CONF="$MAKECONF" SRCCONF="$SRCCONF" \
      CC=$CC CXX=$CXX KERNCONF="GENERIC $KERNEL" TARGET=$TARGET TARGET_ARCH=$TARGET_ARCH \
      buildkernel > "$LOGDIR/buildkernel-$BUILD_ID.log" 2>&1; then
   log "Successfully built kernels GENERIC and $KERNEL (using ccache)"
else
   log "buildkernel failed (using ccache)" 1
   if tail -n 100 "$LOGDIR/buildkernel-$BUILD_ID.log" | grep "Signal 11"; then
      log "buildkernel failed due to internal compiler error (\"Signal 11\").\nMost likely, you have faulty hardware, e.g. bad RAM." 3
      exit 1
   elif tail -n 100 "$LOGDIR/buildkernel-$BUILD_ID.log" | grep "Error code 127"; then
      log "buildkernel failed due to \"Error code 127\"\nMost likely, you have a problem with time on your machine.\nTry syncing time and removing $OBJDIR." 3
      exit 1
   elif MAKEOBJDIRPREFIX="$OBJDIR" make __MAKE_CONF="$MAKECONF" SRCCONF="$SRCCONF" \
         KERNCONF="GENERIC $KERNEL" TARGET=$TARGET TARGET_ARCH=$TARGET_ARCH \
         buildkernel > "$LOGDIR/buildkernel-noccache-$BUILD_ID.log" 2>&1; then
      log "Successfully built kernels GENERIC and $KERNEL (no ccache)"
   else
      log "buildkernel failed (no ccache)"
      log "Skipping this build. Waiting $SLEEP seconds.\nSee $LOGDIR/buildkernel-$BUILD_ID.log and $LOGDIR/buildkernel-noccache-$BUILD_ID.log for details.\n\n" 1
      skip=1
   fi  
fi

