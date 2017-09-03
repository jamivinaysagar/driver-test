# Copyright (C) 2012 Timesys Corporation
#
# spidev Tests

$(eval $(call SETUP_TARGET_DIRS,spidev))

# Test application manifest
spidev_SIMPLE_C=spidev_test mcp3002_test
spidev_SCRIPT=

spidev: $(call STANDARD_DEPS,spidev)

$(eval $(call SETUP_BUILD_RULES,spidev))

# vim:set noexpandtab:
