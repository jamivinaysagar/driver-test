# Copyright (C) 2012 Timesys Corporation

define SETUP_TARGET_DIRS
$1_REL_DIR=$(1)
$1_SRC_DIR=$(BASE_DIR)/target/$$($1_REL_DIR)
$1_OBJ_DIR=$(TARGET_BUILD_DIR)/obj/$$($1_REL_DIR)
$1_BIN_DIR=$(TARGET_BUILD_DIR)/bin/$$($1_REL_DIR)
endef

# vim:set noexpandtab:
