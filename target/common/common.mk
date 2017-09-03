# Copyright (C) 2012 Timesys Corporation
#
# Common setup

build/obj/common/tstp.o: target/common/tstp.c
	@mkdir -p $(@D)
	$(CC) -c $< -Iinclude -o $@

common: build/obj/common/tstp.o

# vim:set noexpandtab:
