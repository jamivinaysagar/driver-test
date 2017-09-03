# Copyright (C) 2012 Timesys Corporation
#
# gpiolib Tests

$(eval $(call SETUP_TARGET_DIRS,gpiolib))

# Test application manifest
gpiolib_SIMPLE_C=
gpiolib_SCRIPT=gpio-toggle.sh

gpiolib: $(call STANDARD_DEPS,gpiolib)

$(eval $(call SETUP_BUILD_RULES,gpiolib))

# vim:set noexpandtab:
