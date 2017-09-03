# Copyright (C) 2012 Timesys Corporation
#
# rtc Tests

$(eval $(call SETUP_TARGET_DIRS,rtc))

# Test application manifest
rtc_SIMPLE_C=rtctest
rtc_SCRIPT=

rtc: $(call STANDARD_DEPS,rtc)

$(eval $(call SETUP_BUILD_RULES,rtc))

# vim:set noexpandtab:
