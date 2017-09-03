# Copyright (C) 2012 Timesys Corporation
#
# gst-fsl Tests

$(eval $(call SETUP_TARGET_DIRS,gst-fsl))

# Test application manifest
gst-fsl_SCRIPT=test_pipelines.sh

gst-fsl: $(call STANDARD_DEPS,gst-fsl)

$(eval $(call SETUP_BUILD_RULES,gst-fsl))

# vim:set noexpandtab:
