# Copyright (C) 2012 Timesys Corporation
#
# LED Tests

$(eval $(call SETUP_TARGET_DIRS,leds))

# Test application manifest
leds_SIMPLE_C=
leds_SCRIPT=led-toggle.sh

leds: $(call STANDARD_DEPS,leds)

$(eval $(call SETUP_BUILD_RULES,leds))

# vim:set noexpandtab:
