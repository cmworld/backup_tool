#!/bin/sh

help(){
cat << HELP
  Usage: backtool_file [PATH] [BAKTO]
  Cutting [LOGFILE] to [SAVETO] by runtime
HELP
exit 0
}

if [ $# -eq 0 ]
then
  echo "ERROR: no option. -h for help";
  exit 0;
elif [ $1 = "-h" ]
then
 help;
 exit 0;
fi

SAVEPATH=$1
BAKTOPATH=$2

var=`echo $SAVEPATH | cut -c 1-1`
if [ "$var" != "/" ]
then
 echo "You must specify an absolute path. Try again";
 exit 0;
fi

if [ ! -d $SAVEPATH ]
then
 echo "ERROR: ${SAVEPATH} does not exist"
 exit 0;
fi

if [ ! -d $BAKTOPATH ]
then
 echo "ERROR: ${BAKTOPATH} does not exist"
 exit 0;
fi

dayofweek=`date +%u`
lastmonth=`date -d last-month +%Y%m`
ym=`date +%Y%m`
ymd=`date +%Y%m%d`
exclude="--exclude=.svn --exclude=.audio --exclude=.mp3"

FULLSTOREDIR=$BAKTOPATH/full
ADDEDSTOREDIR=$BAKTOPATH/added

if [ ! -d $FULLSTOREDIR -o ! -d $ADDEDSTOREDIR ]
then
 mkdir -p -v  $FULLSTOREDIR
 mkdir -p -v  $ADDEDSTOREDIR
fi

checktarname(){
        type=$1
        while [ -e "$BAKTOPATH"/"$type"/"$type"_"$ymd".tar.gz ]
        do
                ymd=`echo "$ymd + 0.1" | bc `
                TARNAME="$type"_"$ymd".tar.gz
        done
}

if [ ! -f "$BAKTOPATH"/snapshot ]; then
        TARNAME=full_"$ymd".tar.gz
        checktarname "full"
        tar $exclude -g "$BAKTOPATH"/snapshot -zcvPf "$FULLSTOREDIR"/"$TARNAME" $SAVEPATH
        exit 0;
fi

if [ $dayofweek -eq 7 ]; then
        rm -rf $BAKTOPATH/snapshot
        TARNAME=full_"$ymd".tar.gz
        checktarname "full"
        tar $exclude -g "$BAKTOPATH"/snapshot -zcvPf "$FULLSTOREDIR"/"$TARNAME" $SAVEPATH
        exit 0;
else
        TARNAME=added_"$ymd".tar.gz
        checktarname "added"
        tar $exclude -g "$BAKTOPATH"/snapshot -zcvPf "$ADDEDSTOREDIR"/"$TARNAME" $SAVEPATH
fi