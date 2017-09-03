#!/bin/sh

# You need the following tools:
# avconv
# libx264

INPUTFILE=$1
OUTPUTNAME=$2

if [[ "$OUTPUTNAME" == "" ]]; then
  OUTPUTNAME=test
fi

avconv -y -i $INPUTFILE -vcodec libx264 -acodec libmp3lame ${OUTPUTNAME}_h264_mp3.avi
avconv -y -i $INPUTFILE -vcodec libx264 -ab 448000 -acodec ac3 ${OUTPUTNAME}_h264_ac3.avi
avconv -y -i $INPUTFILE -vcodec mpeg4 -acodec libmp3lame ${OUTPUTNAME}_mpeg4_mp3.avi
avconv -y -i $INPUTFILE -vcodec msmpeg4 -acodec libmp3lame ${OUTPUTNAME}_msmpeg4_mp3.avi
avconv -y -i $INPUTFILE -ar 22050 ${OUTPUTNAME}_flv_swf.flv
avconv -y -i $INPUTFILE ${OUTPUTNAME}_mpeg4_aac.mp4
avconv -y -i $INPUTFILE -vcodec libx264 ${OUTPUTNAME}_h264_aac.mp4
avconv -y -i $INPUTFILE -vcodec mpeg2video ${OUTPUTNAME}_mpeg2_mp2.mpg
avconv -y -i $INPUTFILE -vcodec wmv2 -acodec wmav2 ${OUTPUTNAME}_wmv_wma.wmv
avconv -y -i $INPUTFILE -vcodec libtheora -acodec libvorbis ${OUTPUTNAME}_theora_vorbis.ogg
avconv -y -i $INPUTFILE -vcodec libx264 -acodec libmp3lame ${OUTPUTNAME}_h264_mp3.mkv

# Audio only
avconv -y -i $INPUTFILE -vn -acodec libvorbis ${OUTPUTNAME}_audio_vorbis.ogg
avconv -y -i $INPUTFILE -vn -ar 16000 -ac 1 -acodec libvo_amrwbenc ${OUTPUTNAME}_audio.amr
