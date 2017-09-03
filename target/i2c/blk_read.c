/*
 * MCP23008 I/O Expander Test Application (using i2c chardev driver)
 *
 * This has been tested with the in-house I2C/SPI test board
 *
 * Copyright (c) 2012 Timesys Corporation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License.
 *
 * Cross-compile with cross-gcc -I/path/to/cross-kernel/include
 */


#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include "i2c-dev.h"

static const char *device = "/dev/i2c-0";

static void print_usage(const char *prog)
{
	printf("Usage: %s [-Dgrydpa]\n", prog);
	puts("  -D --device   device to use (default /dev/i2c-0)\n"
	     "  -g --green    Green LED\n"
	     "  -r --red      Red LED\n"
	     "  -y --yellow   Yellow LED\n"
	     "  -d --adc      ADC\n"
	     "  -p --pullup   Set pullup on auxillary pin\n"
	     "  -a --aux      Auxillary pin (no arg for input)\n");
	exit(1);
}

static void parse_opts(int argc, char *argv[])
{
	while (1) {
		static const struct option lopts[] = {
			{ "device",  1, 0, 'D' },
			{ NULL, 0, 0, 0 },
		};
		int c;

		c = getopt_long(argc, argv, "D::", lopts, NULL);

		if (c == -1)
			break;

		switch (c) {
		case 'D':
			device = optarg;
			break;
		default:
			print_usage(argv[0]);
			break;
		}
	}
}

int main(int argc, char *argv[])
{
	int fd;
	int ret;
	__u8 *block;

	parse_opts(argc, argv);

	fd = open(device, O_RDWR);
	if (fd < 0) {
		printf("%s not found!\n", device);
		exit(1);
	}

	/* Set up the message */
//	ret = ioctl(fd, I2C_SLAVE, MCP23008_ADDR);

	block = malloc(32); //i2c_smbus_read_block_data() can return up to 32 bytes
	ret = i2c_smbus_read_block_data(fd, 0x00, block);

	close(fd);
	return 0;
}
