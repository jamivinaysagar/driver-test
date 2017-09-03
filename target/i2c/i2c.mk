# Copyright (C) 2012 Timesys Corporation
#
# i2c Tests

$(eval $(call SETUP_TARGET_DIRS,i2c))

# Test application manifest
i2c_SIMPLE_C=mcp23008_test blk_read i210_test
i2c_SCRIPT=i2c_send_command.sh i2c_read_verify.sh

i2c: $(call STANDARD_DEPS,i2c)

$(eval $(call SETUP_BUILD_RULES,i2c))

# vim:set noexpandtab:
