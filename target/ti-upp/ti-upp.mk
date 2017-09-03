# Copyright (C) 2012 Timesys Corporation
#
# Texas Instruments Universal Parallel Port (UPP) Tests

$(eval $(call SETUP_TARGET_DIRS,ti-upp))

# Test application manifest
ti-upp_SIMPLE_C=test_loopback

test_loopback_CFLAGS='-lpthread'

ti-upp_SCRIPT=

ti-upp: $(call STANDARD_DEPS,ti-upp)

$(eval $(call SETUP_BUILD_RULES,ti-upp))

# vim:set noexpandtab:
