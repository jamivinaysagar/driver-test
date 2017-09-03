# Copyright (C) 2012 Timesys Corporation
#
# build.mk
#
# This file contains a bunch of macros to help build different
# types of tests.

################################################
# Simple C
#
# Use this build option if you have a single C file
# with no special flags

define SIMPLE_C_BUILD
$$($1_BIN_DIR)/$2: build/obj/common/tstp.o $$($1_OBJ_DIR)/$2.o
	@mkdir -p $$(@D)
	-$$(CC) $$? -Iinclude $$($2_CFLAGS) -o $$@


$$($1_OBJ_DIR)/$2.o: $$($1_SRC_DIR)/$2.c
	@mkdir -p $$(@D)
	-cd $$(<D) && \
		$$(CC) -c $$< -Iinclude $$($2_CFLAGS) -o $$@
endef


################################################
# Shell scripts
#
# Use this option for scripts that simply need to be
# copied into the filesystem

define SCRIPT_BUILD
$$($1_BIN_DIR)/$2: $$($1_SRC_DIR)/$2
	@mkdir -p $$(@D)
	cp $$< $$@
	@chmod a+x $$@
endef


################################################
# Common

define SETUP_TESTS
$(foreach test,$($2_$1),$($2_BIN_DIR)/$(test))
endef

define SETUP_RULES
$$(foreach app,$$($2_$1),$$(eval $$(call $1_BUILD,$2,$$(app))))
endef

define STANDARD_DEPS
$(call SETUP_TESTS,SIMPLE_C,$1) $(call SETUP_TESTS,SCRIPT,$1)
endef

# Use this to set up all of the rules
define SETUP_BUILD_RULES
$(eval $(call SETUP_RULES,SIMPLE_C,$1))
$(eval $(call SETUP_RULES,SCRIPT,$1))

TSTP_TARGET_TESTS+=$1
endef

# vim:set noexpandtab:
