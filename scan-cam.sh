#!/bin/sh
#Shell script to automate cameradar scanning of a list of targets and grabbing
#snapshots from identified cameras
#uses ffmpeg to pull snaps

CAMERADAR="$HOME/go/bin/cameradar"
CREDS="$HOME/go/src/github.com/EtixLabs/cameradar/dictionaries/credentials.json"
ROUTES="$HOME/go/src/github.com/EtixLabs/cameradar/dictionaries/routes"
CAMDAR="$HOME/camdar"
CTMP="$CAMDAR/tmp"
SNAPS="$CAMDAR/snapshots"
TGT="$1"
DATE=$(date +Y-%M-%d)
######################################
#####Functions
#base cameradar dir setup
_setup()
    {
        if [ ! -d $CAMDAR ] ; then
            mkdir -p $CAMDAR
            mkdir -p $CTP
            mkdir -p $SNAPS
        fi
    }
#Run cameradar and redirect output to results file
_run_cameradar()
    {
        exec &> $CTMP/$DATE.results.txt
        while read i; do
            $CAMERADAR -t $i -c $CREDS -r $ROUTES
        done < $1
    }
_get_targets()
    {
       cat $CTMP/$DATE.results.txt | grep -o 'rtsp://.*' > $CTMP/$DATE.targets.txt
   }

_get_snaps()
    {
        while read LINE 
            do
                IP=$(echo $LINE | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])')
                ffmpeg -loglevel fatal -i $LINE -vframes 1 -r 1 $SNAPS/$DATE.$IP.jpg
            done < $CTMP/$DATE.targets.txt
}
####Main
_setup
_run_cameradar $TGT
_get_targets
_get_snaps
