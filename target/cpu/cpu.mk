# Copyright (C) 2012 Timesys Corporation
#
# cpu Tests

$(eval $(call SETUP_TARGET_DIRS,cpu))

# Test application manifest
cpu_SIMPLE_C=
cpu_SCRIPT=test_cpufreq.sh

cpu: $(call STANDARD_DEPS,cpu)

$(eval $(call SETUP_BUILD_RULES,cpu))

# vim:set noexpandtab:
