# $destdir_prefix comes from local_src_mod.sh. If this script is unused, the var will be empty
DESTDIR="$SRCPKGDIR/$destdir_prefix$DATE/full"
mkdir -p "$DESTDIR"
log "Installing files to $DESTDIR"
log "Installing world"
if ! MAKEOBJDIRPREFIX=$OBJDIR make installworld TARGET=$TARGET TARGET_ARCH=$TARGET_ARCH \
      __MAKE_CONF=$MAKECONF SRCCONF=$SRCCONF  DESTDIR="$DESTDIR" \
      > "$LOGDIR/installworld-$DATE.log" 2>&1; then
   log "installworld failed. See $LOGDIR/installworld-$DATE.log for details." 3
   exit 1
fi
log "Installing distribution"
if ! MAKEOBJDIRPREFIX=$OBJDIR make distribution TARGET=$TARGET TARGET_ARCH=$TARGET_ARCH \
      __MAKE_CONF=$MAKECONF SRCCONF=$SRCCONF  DESTDIR="$DESTDIR" \
      > "$LOGDIR/distribution-$DATE.log" 2>&1; then
   log "make distribution failed. See $LOGDIR/distribution-$DATE.log for details." 3
   exit 1
fi
log "Installing kernels"
if ! MAKEOBJDIRPREFIX=$OBJDIR make installkernel KERNCONF="$KERNEL" TARGET=$TARGET \
      TARGET_ARCH=$TARGET_ARCH __MAKE_CONF=$MAKECONF SRCCONF=$SRCCONF  \
      DESTDIR="$DESTDIR" > "$LOGDIR/installkernel-$DATE.log" 2>&1; then
   log "installkernel ($KERNEL) failed. See $LOGDIR/installkernel-$DATE.log for details." 3
fi
if ! MAKEOBJDIRPREFIX=$OBJDIR make installkernel KERNCONF=GENERIC TARGET=$TARGET \
      TARGET_ARCH=$TARGET_ARCH __MAKE_CONF=$MAKECONF SRCCONF=$SRCCONF DESTDIR="$DESTDIR" \
      INSTKERNNAME=GENERIC > "$LOGDIR/installkernel-generic-$DATE.log" 2>&1; then
   log "installkernel (GENERIC) failed. See $LOGDIR/installkernel-generic-$DATE.log for details." 3
   exit 1
fi
