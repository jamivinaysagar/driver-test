# Copyright (C) 2012 Timesys Corporation
#
# hwmon Tests

$(eval $(call SETUP_TARGET_DIRS,hwmon))

# Test application manifest
hwmon_SIMPLE_C=
hwmon_SCRIPT=test_adc.sh

hwmon: $(call STANDARD_DEPS,hwmon)

$(eval $(call SETUP_BUILD_RULES,hwmon))

# vim:set noexpandtab:
