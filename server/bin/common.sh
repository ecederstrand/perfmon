# Logging function. Example use: log "my message" 2
log() {
   case $2 in
      0)  
         msg="$1"
         ;;  
      1)  
         msg="WARNING: $1"
         ;;  
      2)  
         msg="CRITICAL: $1"
         ;;  
      3)  
         msg="FATAL: $1\nAborting"
         ;;  
      *)  
         msg="$1"
         ;;  
   esac

   now=`date "+%F %T"`

   if [ -n "$LOG" ]; then
      echo -e "$now: $msg" >> "$LOG"
      if [ "X$2" = "X3" ]; then     # $2 may be empty
        echo -e "$msg"              # Also output fatal errors to stdout
        if [ -n "$EMAIL" ]; then
            # If an email address was given, also send the notification there
            echo "I'm sorry. An error occurred when building your image: $msg" | mail -s "Message from PerfMon" $EMAIL
        fi
      fi
   else
      echo -e "$now: $msg"
   fi
}

