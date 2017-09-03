# Copyright (C) 2012 Timesys Corporation
#
# fb Tests

$(eval $(call SETUP_TARGET_DIRS,fb))

# Test application manifest
fb_SIMPLE_C=
fb_SCRIPT=test_x11.sh test_weston.sh colorbar_1920x1080.png colorbar_1024x768.png

fb: $(call STANDARD_DEPS,fb)

$(eval $(call SETUP_BUILD_RULES,fb))

# vim:set noexpandtab:
