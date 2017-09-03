# Copyright (C) 2012 Timesys Corporation
#
# filesystem Tests

$(eval $(call SETUP_TARGET_DIRS,fs))

# Test application manifest
fs_SIMPLE_C=
fs_SCRIPT=test_fs.sh test_ubi_jffs.sh

fs: $(call STANDARD_DEPS,fs)

$(eval $(call SETUP_BUILD_RULES,fs))

# vim:set noexpandtab:
