# Copyright (C) 2012 Timesys Corporation
#
# watchdog Tests

$(eval $(call SETUP_TARGET_DIRS,watchdog))

# Test application manifest
watchdog_SIMPLE_C=watchdog-simple watchdog-test
watchdog_SCRIPT=

watchdog: $(call STANDARD_DEPS,watchdog)

$(eval $(call SETUP_BUILD_RULES,watchdog))

# vim:set noexpandtab:
