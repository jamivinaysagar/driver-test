# Copyright (C) 2012 Timesys Corporation
#
# audio Tests

$(eval $(call SETUP_TARGET_DIRS,audio))

# Test application manifest
audio_SIMPLE_C=
audio_SCRIPT=test_mic.sh test_line.sh test_speaker.sh 500Hz_48000.wav

audio: $(call STANDARD_DEPS,audio)

$(eval $(call SETUP_BUILD_RULES,audio))

# vim:set noexpandtab:
