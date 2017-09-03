# Copyright (C) 2012 Timesys Corporation

BASE_DIR=$(shell pwd)
TARGET_BUILD_DIR=$(BASE_DIR)/build
HOST_BUILD_DIR=$(BASE_DIR)/build_host
PREFIX?=usr/tstp

all: target-tests

-include include/*.mk
-include $(BASE_DIR)/target/*/*.mk

target-tests: $(TSTP_TARGET_TESTS)

install: all
	mkdir -p $(DESTDIR)/$(PREFIX)
	mkdir -p $(DESTDIR)/$(PREFIX)/bin
	cp -r target/common/Test.sh $(DESTDIR)/$(PREFIX)/
	-cp automated.conf interactive.conf $(DESTDIR)/$(PREFIX)/
	cp -r $(TARGET_BUILD_DIR)/bin/* $(DESTDIR)/$(PREFIX)/bin

clean:
	rm -rf $(TARGET_BUILD_DIR)

distclean:
	rm -rf $(TARGET_BUILD_DIR) $(HOST_BUILD_DIR)

help:
	@echo ''
	@echo 'Timesys Test Project (TSTP)'
	@echo ''
	@echo 'The Timesys Test Project is a number of collection of'
	@echo 'tests designed to help developers identify regressions'
	@echo 'and bugs in a Linux System.'
	@echo ''
	@echo 'Targets:'
	@echo '  install          - Install target applications to DESTDIR'
	@echo '  clean            - Remove all generated files for target'
	@echo '  distclean        - Remove all generated files for target and host'
	@echo '* target-tests     - Build all of the tests'
	@echo ''

.PHONY: target-tests clean distclean install help $(TSTP_TARGET_TESTS)

# vim:set noexpandtab:
