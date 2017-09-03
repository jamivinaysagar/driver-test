/*
 * Common Test Functions for Timesys Test Project
 *
 * Copyright (c) 2015 Timesys Corporation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License.
 */

#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <tstp.h>


inline int tstp_success(void)
{
	printf("SUCCESS\n");
	return 0;
}

inline int tstp_fail(int errno)
{
	printf("FAILURE\n");
	return errno;
}
