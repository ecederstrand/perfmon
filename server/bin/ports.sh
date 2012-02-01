cp /etc/resolv.conf "$DESTDIR"/etc/ # fetch doesn't work without this
cp "$SLAVEDIR"/conf/make.conf "$DESTDIR"/etc # make options for chroot install to work
# A WRKDIRPREFIX=/tmp must be present to the chroot's make.conf
# Copy port config options to DESTDIR, so we can batch-install
mkdir -p "$DESTDIR"/var/db/ports
cp -R "$SLAVEDIR"/ports/options/* "$DESTDIR"/var/db/ports

# Add various mounts for the chroot to work
mount -t devfs devfs "$DESTDIR"/dev  # Only needed for jails?
mount -t procfs proc "$DESTDIR"/proc # Only needed for jails?
mkdir -p "$DESTDIR"/usr/ports
mount_nullfs "$PORTSDIR" "$DESTDIR"/usr/ports

while read line
do
   # portslist.conf entries must be of the form somecategory/someport
   # Strip comments and leading/trailing whitespaces
   line=`echo $line | sed 's/#.*//; s/^[ \t]*//; s/[ \t]*$//'`
   [ "$line" = "" ] && continue # Skip empty lines and comments

   if [ -d "$PORTSDIR/$line" ]; then
      cd "$PORTSDIR/$line"
      log "Installing $line"
      portname=`echo $line | sed s,.*/,,` # Strip the directory part of the line
      # if ! make install clean DESTDIR="$DESTDIR" > "$LOGDIR/install-$portname-$DATE.log" 2>&1; then
      # DESTDIR is buggy somehow. Use chroot directly instead.
      if ! chroot "$DESTDIR" /bin/sh -c "cd /usr/ports/$line; WRKDIRPREFIX=/tmp make BATCH=yes install clean; " \
            > "$LOGDIR/install-$portname-$DATE.log" 2>&1; then
         log "Failed to install $line. See $LOGDIR/install-$portname-$DATE.log for details." 1
         skip=1
      fi
   else
      log "$PORTSIR/$line not found." 3
      umount "$DESTDIR"/dev
      umount "$DESTDIR"/proc
      umount "$DESTDIR"/usr/ports
      exit 1
   fi
done < "$SLAVEDIR"/ports/portlist.conf

# Clean up
# rm -r "$DESTDIR"/tmp/* # make install clean does this?
umount "$DESTDIR"/dev
umount "$DESTDIR"/proc
umount "$DESTDIR"/usr/ports

