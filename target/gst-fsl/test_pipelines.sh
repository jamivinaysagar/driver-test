#!/bin/sh

INPUTFILE=$1
OUTPUTFILE=$1
MODE=$2
INPUTFILE2=$3

AUDIODEV=
VIDEODEV=
FPS=15
CAPTUREMODE=0
CODEC=6
MUXNAME=matroskamux

if [[ "$AUDIODEV" != "" ]] ; then
    AUDIOHW=device="$AUDIODEV"
fi

if [[ "$VIDEODEV" != "" ]]; then
    VIDEOHW=device="$VIDEODEV"
fi

case $MODE in
    # Video Decode Only
    1 )
        gst-launch filesrc location=$INPUTFILE typefind=true \
             ! aiurdemux name=demux demux. ! queue max-size-time=0 ! vpudec ! mfw_v4lsink $VIDEOHW demux.
        ;;

    # Audio Decode Only
    2 )
        gst-launch filesrc location=$INPUTFILE typefind=true \
             ! aiurdemux name=demux demux. ! queue max-size-time=0 ! vpudec ! mfw_v4lsink $VIDEOHW demux. \
             ! queue max-size-time=0 ! beepdec ! audioconvert ! 'audio/x-raw-int, channels=2' ! alsasink $AUDIOHW demux.
        ;;

    # Video and Audio Decode
    3 )
        gst-launch filesrc location=$INPUTFILE typefind=true \
             ! aiurdemux name=demux demux. ! queue max-size-time=0 ! vpudec ! mfw_v4lsink $VIDEOHW demux. \
             ! queue max-size-time=0 ! beepdec ! audioconvert ! 'audio/x-raw-int, channels=2' ! alsasink $AUDIOHW demux.
        ;;

    # Video Pass-Through
    4 )
        gst-launch mfw_v4lsrc fps-n=$FPS capture-mode=$CAPTUREMODE ! mfw_v4lsink $VIDEOHW
        ;;

    # Video Capture
    5 )
        gst-launch mfw_v4lsrc fps-n=$FPS capture-mode=$CAPTUREMODE ! queue \
             ! vpuenc codec=$CODEC ! $MUXNAME ! filesink location=$OUTPUTFILE sync=false
        ;;

    # Audio Pass-Through
    6 )
        gst-launch alsasrc ! alsasink
        ;;

    # Audio Capture
    7)
        gst-launch alsasrc num-buffers=240 blocksize=44100 ! mfw_mp3encoder ! filesink location=$OUTPUTFILE
        ;;

    # Video and Audio Capture and Playback
    8)
        gst-launch matroskamux name=mux ! filesink location=$OUTPUTFILE \
             alsasrc ! mfw_mp3encoder ! mux. \
             mfw_v4lsrc fps-n=$FPS capture-mode=$CAPTUREMODE ! queue ! vpuenc codec=$CODEC ! mux.
        ;;

    # AMR Audio Playback
    9 )
        gst-launch filesrc location=$INPUTFILE typefind=true  
             ! amrparse ! mfw_amrdecoder ! audioconvert  
             ! audio/x-raw-int, channels=2 ! alsasink $AUDIOHW
        ;;

    # Video Decode Using IPU
    10 )
        gst-launch filesrc location=$INPUTFILE typefind=true \
             ! aiurdemux name=demux demux. ! queue max-size-time=0 ! vpudec \
             ! mfw_isink axis-top=100 axis-left=100 disp-width=640 disp-height=480 demux.
        ;;

    # Video Decode Two Videos Using IPU
    11 )
        gst-launch \
             filesrc location=$INPUTFILE typefind=true \
                 ! aiurdemux name=demux1 demux1. ! queue max-size-time=0 ! vpudec \
                 ! mfw_isink axis-top=0 axis-left=0 disp-width=320 disp-height=240 demux1. \
             filesrc location=$INPUTFILE2 typefind=true \
                 ! aiurdemux name=demux2 demux2. ! queue max-size-time=0 ! vpudec \
                 ! mfw_isink axis-top=0 axis-left=320 disp-width=320 disp-height=240 demux2.
        ;;

    # Video Decode Two Videos Using IPU on two different displays
    12 )
        gst-launch \
             filesrc location=$INPUTFILE typefind=true \
                 ! aiurdemux name=demux1 demux1. ! queue max-size-time=0 ! vpudec \
                 ! mfw_isink display="master" disp-width=320 disp-height=240 demux1. \
             filesrc location=$INPUTFILE2 typefind=true \
                 ! aiurdemux name=demux2 demux2. ! queue max-size-time=0 ! vpudec \
                 ! mfw_isink display="slave" disp-width=320 disp-height=240 demux2.
        ;;

esac
