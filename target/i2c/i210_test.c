/*
 * Intel i210 SMBus Test Application (using i2c chardev driver)
 *
 * Copyright (c) 2015 Timesys Corporation
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

#define I210_SLAVE_ADDR 0x49

#define I210_CMD_READ_STATUS	0xC0
#define I210_CMD_GET_MAC	0xD4

static char *device = "/dev/i2c-0";

static void print_usage(const char *prog)
{
	printf("Usage: %s [-Dgrydpa]\n", prog);
	puts("  -D --device   device to use (default /dev/i2c-0)\n");
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

#define PRINT_STATUS(name, reg, bit, trueval, falseval) \
			{ printf("%s: %s\n", name, (reg & (1 << bit))?trueval:falseval); }

int get_block(int fd, __u8 *buffer, __u8 command, __u8 opcode, int size)
{
	int ret;

	ret = i2c_smbus_read_block_data(fd, command, buffer);
	if (ret > 0) {
		int i;

		printf("Read %d bytes: [ ", ret);
		for (i = 0; i < ret; i++) {
			printf("0x%02x ", buffer[i]);
		}
		printf("]\n");

		if (ret != size) {
			printf("Error: Expected %d bytes, received %d\n", size, ret);
			return 1;
		}

		if (buffer[0] != opcode) {
			printf("Error: Incorrect op code 0x%02x\n", buffer[0]);
			return 1;
		}
	} else {
		printf("Error: Read failure\n");
		return 1;
	}

	return 0;
}

int main(int argc, char *argv[])
{
	int fd;
	int ret;
	__u8 block[32]; /* i2c_smbus_read_block_data() can return up to 32 bytes */

	parse_opts(argc, argv);

	fd = open(device, O_RDWR);
	if (fd < 0) {
		printf("%s not found!\n", device);
		exit(1);
	}

	/* Set up the message */
	ret = ioctl(fd, I2C_SLAVE, I210_SLAVE_ADDR);

	/* Read status bytes */
	printf("\nStatus Register\n");
	printf("===============\n");
	if (get_block(fd, block, I210_CMD_READ_STATUS, 0xdd, 3) == 0) {
		PRINT_STATUS("TCO Command Aborted", block[1], 6, "True", "False");
		PRINT_STATUS("Link Status", block[1], 5, "Up", "Down");
		PRINT_STATUS("PHY Link Force Up", block[1], 4, "True", "False");
		PRINT_STATUS("Initialization Indication", block[1], 3, "Yes", "No");

		printf("Power State: ");
		switch (block[1] & 0x3) {
		case 0:
			printf("Dr\n");
			break;
		case 1:
			printf("D0u\n");
			break;
		case 2:
			printf("D0\n");
			break;
		case 3:
			printf("D3\n");
			break;
		}

		PRINT_STATUS("Driver Valid", block[1], 3, "Alive", "Not Alive");
		PRINT_STATUS("Interrupt Pending", block[1], 2, "Yes", "No");
		PRINT_STATUS("Interrupt Cause", block[2], 1, "Read", "Not Read");
	} else {
		close(fd);
		exit(1);
	}

	/* Read MAC Address */
	printf("\nGet MAC Address\n");
	printf("================\n");
	if (get_block(fd, block, I210_CMD_GET_MAC, 0xd4, 7) == 0) {
		int i;

		printf("MAC Address: ");
		for (i = 1; i < 7; i++) {
			printf("%02X%s", block[i], (i == 6)?"":":");
		}
		printf("\n");
	}

	close(fd);
	return 0;
}
