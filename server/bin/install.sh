BRANCHDIR="$SRCPKGDIR/$BRANCH_ID"
REVDIR="$BRANCHDIR/r$REV"
DESTDIR="$REVDIR/full"
mkdir -p "$DESTDIR"

log "Installing files to $DESTDIR"
log "Installing world"
if ! MAKEOBJDIRPREFIX=$OBJDIR make installworld TARGET=$TARGET TARGET_ARCH=$TARGET_ARCH \
      __MAKE_CONF=$MAKECONF SRCCONF=$SRCCONF  DESTDIR="$DESTDIR" \
      > "$LOGDIR/installworld-$BUILD_ID.log" 2>&1; then
   log "installworld failed. See $LOGDIR/installworld-$BUILD_ID.log for details." 3
   exit 1
fi
log "Installing distribution"
if ! MAKEOBJDIRPREFIX=$OBJDIR make distribution TARGET=$TARGET TARGET_ARCH=$TARGET_ARCH \
      __MAKE_CONF=$MAKECONF SRCCONF=$SRCCONF  DESTDIR="$DESTDIR" \
      > "$LOGDIR/distribution-$BUILD_ID.log" 2>&1; then
   log "make distribution failed. See $LOGDIR/distribution-$BUILD_ID.log for details." 3
   exit 1
fi
log "Installing kernels"
if ! MAKEOBJDIRPREFIX=$OBJDIR make installkernel KERNCONF="$KERNEL" TARGET=$TARGET \
      TARGET_ARCH=$TARGET_ARCH __MAKE_CONF=$MAKECONF SRCCONF=$SRCCONF  \
      DESTDIR="$DESTDIR" > "$LOGDIR/installkernel-$BUILD_ID.log" 2>&1; then
   log "installkernel ($KERNEL) failed. See $LOGDIR/installkernel-$BUILD_ID.log for details." 3
fi
if ! MAKEOBJDIRPREFIX=$OBJDIR make installkernel KERNCONF=GENERIC TARGET=$TARGET \
      TARGET_ARCH=$TARGET_ARCH __MAKE_CONF=$MAKECONF SRCCONF=$SRCCONF DESTDIR="$DESTDIR" \
      INSTKERNNAME=GENERIC > "$LOGDIR/installkernel-generic-$BUILD_ID.log" 2>&1; then
   log "installkernel (GENERIC) failed. See $LOGDIR/installkernel-generic-$BUILD_ID.log for details." 3
   exit 1
fi
