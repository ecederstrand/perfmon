#!/bin/sh

# This file scrapes the cvs-src commit messages from lists.freebsd.org and 
# processes them for inclusion in a database. The intent is to make a search-
# able system for commit messages and to compare cvs dates and see which files
# have changed between these dates. Another use case is compating two cvs dates
# and determining if they represent the same source code.
#
# It is important to note that the cvs commit program that emits the cvs-src
# messages makes some assumptions on which files were committed together and
# when, since CVS doesn't retain this information. These assumptions may not 
# be 100% correct.
#
# Use: ./commits.sh [year] [months]
#
# Example: ./commits.sh 2007 "January February March"
#

BASE="http://lists.freebsd.org/pipermail/cvs-src"
if [ -n "$1" ]; then
    YEAR="$1"
else
    YEAR=`date -ju "+%Y"`
fi

if [ -n "$2" ]; then
    MONTHS="$2"
else
    MONTHS="January February March April May June July August September October November December"
fi

OUTPUT="cvs_log_insert.sql"

for MONTH in $MONTHS
do
    # Fetch email index page and scrape links to messages
    files=`fetch -T 60 -aqo - $BASE/$YEAR-$MONTH/date.html | grep "A HREF.*cvs commit" | sed 's/<LI.*HREF="//;s/html">.*/html/'`

    # Change default split character of "for" loop
    IFS='
'
    i=0

    # Count potential commit messages
    n=`echo "$files" | wc -l | awk '{ print $1 }' | tr -d '\n'`
    echo -e "\nProcessing $n commit messages from $MONTH"

    # Fetch messages one by one
    for file in $files
    do
        # Emit a status report
        i=$(( $i + 1 ))
        if [ "$(( $i % 100 ))" -eq "0" ]; then
            echo -n "$i"
        elif [ "$(( $i % 10 ))" -eq "0" ]; then
            echo -n "."
        fi

        page=`fetch -T 60 -aqo - $BASE/$YEAR-$MONTH/$file`
        # Ignore replies to commit messages
        if echo $page | grep -q 'In-Reply-To=">'; then
            #echo "-- $file" >> $OUTPUT
            do_echo=0
     
            # Scrape relevant information
            for line in $page
            do
                if echo $line | grep -q '<PRE>'; then
                    committer=`echo $line | sed 's/<PRE>//' | awk '{ print $1 }' | tr -d '\n'`
                    date=`echo $line | sed 's/<PRE>//' | awk '{ print $2, $3 }' | tr -d '\n'`
                    continue
                fi
                if echo $line | grep -q '(Branch:'; then
                    branch=`echo $line | sed 's/.*Branch: //;s/)//' | tr -d '\n'`
                    continue
                fi
                if echo $line | grep -q 'Revision.*Changes.*Path'; then
                    do_echo=1
                    continue
                fi
                if echo $line | grep -q '</PRE>'; then
                    do_echo=0
                    continue
                fi
                if [ "$do_echo" -eq 1 ]; then
                    filename=`echo $line | awk '{ print $4 }' | tr -d '\n'`
                    revision=`echo $line | awk '{ print $1 }' | tr -d '\n'`
                    # Add some rudimentary error checking
                    if echo $filename | grep -q 'src/'; then
                        if [ -n "$branch" ]; then
                            echo "insert into cvs_log (date, branch, committer, filename, revision) values ('$date', '$branch', '$committer', '$filename', '$revision');" >> $OUTPUT
                        else
                            echo "insert into cvs_log (date, committer, filename, revision) values ('$date', '$committer', '$filename', '$revision');" >> $OUTPUT
                        fi
                    fi
                fi
            done

            # Reset values
            unset committer
            unset date
            unset branch
            unset filename
            unset revision
        #else
        #    echo "Discarding $BASE/$YEAR-$MONTH/$file (it looks like a comment)"
        fi
    done
done

echo " Done."
