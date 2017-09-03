/*
 * MCP3002 ADC Test Application (using spidev driver)
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
#include <linux/spi/spidev.h>

static void pabort(const char *s)
{
	perror(s);
	abort();
}

static const char *device = "/dev/spidev1.1";
static unsigned int channel = 1;

static void print_usage(const char *prog)
{
	printf("Usage: %s [-D]\n", prog);
	puts("  -D --device   device to use (default /dev/spidev1.1)\n"
	     "  -s --speed    max speed (Hz)\n"
	     "  -b --bpw      bits per word \n"
	     "  -c --channel  ADC Channel (default 1)\n");
	exit(1);
}

static uint32_t speed = 0;
static uint8_t bpw = 0;

static void parse_opts(int argc, char *argv[])
{
	while (1) {
		static const struct option lopts[] = {
			{ "device",  1, 0, 'D' },
			{ "channel",  1, 0, 'c' },
			{ "speed",   1, 0, 's' },
			{ "bpw",     1, 0, 'b' },
			{ NULL, 0, 0, 0 },
		};
		int c;

		c = getopt_long(argc, argv, "D:c:s:b:", lopts, NULL);

		if (c == -1)
			break;

		switch (c) {
		case 'D':
			device = optarg;
			break;
		case 'c':
			channel = atoi(optarg);
			if(channel != 1 && channel != 2) {
				printf("Invalid Channel (Must be 1 or 2)\n");
				print_usage(argv[0]);
			}
			break;
		case 's':
			speed = atoi(optarg);
			break;
		case 'b':
			bpw = atoi(optarg);
			break;
		default:
			print_usage(argv[0]);
			break;
		}
	}
}

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))

int main(int argc, char *argv[])
{
	int ret = 0;
	int fd;
	uint16_t result;
	double result_volt;

	/* Buffers */
	const uint8_t read_ch1[] = { 0xD0, 0x00 };
	const uint8_t read_ch2[] = { 0xF0, 0x00 };
	uint8_t rx[2] = {0, };

	/* Transfer structure */
	struct spi_ioc_transfer tr = {
		.rx_buf = (unsigned long)rx,
		.len = ARRAY_SIZE(rx),		/* Length (in bytes) of transfer */
	};

	parse_opts(argc, argv);

	/* Open the device */
	fd = open(device, O_RDWR);
	if (fd < 0)
		pabort("can't open device");

	/* Set up the transmit buffer based on the channel */
	if(channel == 1)
		tr.tx_buf = (unsigned long)read_ch1;
	else if (channel == 2)
		tr.tx_buf = (unsigned long)read_ch2;

	/* Set up transfer parameters */
	tr.speed_hz = speed;
	tr.bits_per_word = bpw;

	/* Send the message */
	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1)
		pabort("can't send spi message");

	/* Read the rx register and display the results */
	result = rx[0] & 0x7;
	result = (result << 8) | rx[1];
	result_volt = (double) result / (double) 0x7ff * 3.33333;

	printf("%.4fV (0x%x)\n", result_volt, result);

	/* Clean up */
	close(fd);

	return ret;
}
