# Copyright (C) 2012 Timesys Corporation
#
# pcie Tests

$(eval $(call SETUP_TARGET_DIRS,pcie))

# Test application manifest
pcie_SIMPLE_C=
pcie_SCRIPT=test_pcie_enumeration.sh

pcie: $(call STANDARD_DEPS,pcie)

$(eval $(call SETUP_BUILD_RULES,pcie))

# vim:set noexpandtab:
