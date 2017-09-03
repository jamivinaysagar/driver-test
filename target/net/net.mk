# Copyright (C) 2012 Timesys Corporation
#
# net Tests

$(eval $(call SETUP_TARGET_DIRS,net))

# Test application manifest
net_SIMPLE_C=
net_SCRIPT=test_eth.sh test_wlan.sh test_mdio.sh

net: $(call STANDARD_DEPS,net)

$(eval $(call SETUP_BUILD_RULES,net))

# vim:set noexpandtab:
