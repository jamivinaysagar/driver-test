# Copyright (C) 2012 Timesys Corporation
#
# eeprom Tests

$(eval $(call SETUP_TARGET_DIRS,eeprom))

# Test application manifest
eeprom_SIMPLE_C=
eeprom_SCRIPT=test_eeprom.sh

eeprom: $(call STANDARD_DEPS,eeprom)

$(eval $(call SETUP_BUILD_RULES,eeprom))

# vim:set noexpandtab:
