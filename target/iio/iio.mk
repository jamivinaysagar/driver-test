# Copyright (C) 2012 Timesys Corporation
#
# iio Tests

$(eval $(call SETUP_TARGET_DIRS,iio))

# Test application manifest
iio_SIMPLE_C=
iio_SCRIPT=test_accelerometer.sh test_altimeter.sh

iio: $(call STANDARD_DEPS,iio)

$(eval $(call SETUP_BUILD_RULES,iio))

# vim:set noexpandtab:
