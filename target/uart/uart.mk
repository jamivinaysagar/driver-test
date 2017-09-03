# Copyright (C) 2012 Timesys Corporation
#
# uart Tests

$(eval $(call SETUP_TARGET_DIRS,uart))

# Test application manifest
uart_SIMPLE_C=uart-loopback linux-serial-test
uart_SCRIPT=

uart: $(call STANDARD_DEPS,uart)

$(eval $(call SETUP_BUILD_RULES,uart))

# vim:set noexpandtab:
