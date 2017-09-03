# Copyright (C) 2012 Timesys Corporation
#
# Texas Instruments Universal Parallel Port (UPP) Tests

$(eval $(call SETUP_TARGET_DIRS,imx_adc))

# Test application manifest
imx_adc_SIMPLE_C=test_adc

imx_adc_SCRIPT=

imx_adc: $(call STANDARD_DEPS,imx_adc)

$(eval $(call SETUP_BUILD_RULES,imx_adc))

# vim:set noexpandtab:
