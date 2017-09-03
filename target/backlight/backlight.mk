# Copyright (C) 2012 Timesys Corporation
#
# LED Tests

$(eval $(call SETUP_TARGET_DIRS,backlight))

# Test application manifest
backlight_SIMPLE_C=
backlight_SCRIPT=backlight-test.sh

backlight: $(call STANDARD_DEPS,backlight)

$(eval $(call SETUP_BUILD_RULES,backlight))

# vim:set noexpandtab:
