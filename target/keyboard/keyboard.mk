# Copyright (C) 2012 Timesys Corporation
#
# keyboard Tests

$(eval $(call SETUP_TARGET_DIRS,keyboard))

# Test application manifest
keyboard_SIMPLE_C=button-test
keyboard_SCRIPT=

keyboard: $(call STANDARD_DEPS,keyboard)

$(eval $(call SETUP_BUILD_RULES,keyboard))

# vim:set noexpandtab:
