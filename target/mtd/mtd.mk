# Copyright (C) 2012 Timesys Corporation
#
# mtd Tests

$(eval $(call SETUP_TARGET_DIRS,mtd))

# Test application manifest
mtd_SIMPLE_C=
mtd_SCRIPT=test_nor.sh test_nand.sh

mtd: $(call STANDARD_DEPS,mtd)

$(eval $(call SETUP_BUILD_RULES,mtd))

# vim:set noexpandtab:
