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

#define MCP23008_ADDR 0x20

static const char *device = "/dev/i2c-0";

/* Registers */
#define MCP23008_IODIR		0x00
#define MCP23008_IPOL		0x01
#define MCP23008_GPINTEN	0x02
#define MCP23008_DEFVAL		0x03
#define MCP23008_INTCON		0x04
#define MCP23008_IOCON		0x05
#define MCP23008_GPPU		0x06
#define MCP23008_INTF		0x07
#define MCP23008_INTCAP		0x08
#define MCP23008_GPIO		0x09
#define MCP23008_OLAT		0x0a

#define MCP32008_IOCON_INTPOL	(1 << 1)
#define MCP32008_IOCON_ODR	(1 << 2)
#define MCP32008_IOCON_HAEN	(1 << 3)
#define MCP32008_IOCON_DISSLW	(1 << 4)
#define MCP32008_IOCON_SREAD	(1 << 5)

enum IO {
	IO_GREEN = 0,
	IO_RED,
	IO_YELLOW,
	IO_AUX,
	IO_ADC,
	IO_BUTTON,
};

inline unsigned int get_bit(int file, unsigned char reg, enum IO io)
{
	unsigned char reg_val = i2c_smbus_read_byte_data(file,reg);

	reg_val &= (1 << io);

	return (reg_val)?1:0;
}

inline void set_bit(int file,
			     unsigned char reg,
                             enum IO offset,
			     unsigned int val)
{
	unsigned char reg_val = i2c_smbus_read_byte_data(file,reg);

	if(val)
		reg_val |= 1 << offset;
	else
		reg_val &= ~(1 << offset);

	i2c_smbus_write_byte_data(file, reg, reg_val);
}

#define get_val(file,io)	get_bit(file,MCP23008_GPIO,io)
#define set_val(file,io,val)				\
	{ 						\
		set_bit(file,MCP23008_GPIO,io,val);	\
		set_bit(file,MCP23008_OLAT,io,val);	\
	}

/* Auxillary I/O Port */
#define set_aux_dir(fd,input)	set_bit(fd, MCP23008_IODIR, IO_AUX, input);
#define set_aux_pu(fd,on)	set_bit(fd, MCP23008_GPPU, IO_AUX, on);

int green = -1;
int red = -1;
int yellow = -1;
int adc = -1;
int pullup = -1;
int aux = -1;
int auxin = -1;

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
			{ "green",  1, 0, 'g' },
			{ "red",  1, 0, 'r' },
			{ "yellow",  1, 0, 'y' },
			{ "adc",  1, 0, 'd' },
			{ "pullup",  1, 0, 'p' },
			{ "aux",  2, 0, 'a' },
			{ NULL, 0, 0, 0 },
		};
		int c;

		c = getopt_long(argc, argv, "D:g:r:y:d:p:a::", lopts, NULL);

		if (c == -1)
			break;

		switch (c) {
		case 'D':
			device = optarg;
			break;
		case 'g':
			green = atoi(optarg);
			if(green != 0 && green != 1) {
				printf("Value must be 0 or 1\n");
				print_usage(argv[0]);
			}
			break;
		case 'r':
			red = atoi(optarg);
			if(red != 0 && red != 1) {
				printf("Value must be 0 or 1\n");
				print_usage(argv[0]);
			}
			break;
		case 'y':
			yellow = atoi(optarg);
			if(yellow != 0 && yellow != 1) {
				printf("Value must be 0 or 1\n");
				print_usage(argv[0]);
			}
			break;
		case 'd':
			adc = atoi(optarg);
			if(adc != 0 && adc != 1) {
				printf("Value must be 0 or 1\n");
				print_usage(argv[0]);
			}
			break;
		case 'p':
			pullup = atoi(optarg);
			if(pullup != 0 && pullup != 1) {
				printf("Value must be 0 or 1\n");
				print_usage(argv[0]);
			}
			break;
		case 'a':
			if(optarg) {
				aux = atoi(optarg);
				if(aux != 0 && aux != 1) {
					printf("Value must be 0 or 1\n");
					print_usage(argv[0]);
				}
			} else {
				auxin = 1;
			}
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

	parse_opts(argc, argv);

	fd = open(device, O_RDWR);
	if (fd < 0) {
		printf("File not found!\n");
		exit(1);
	}

	/* Set up the message */
	ret = ioctl(fd, I2C_SLAVE, MCP23008_ADDR);

	/* Setup direction and pullups */
	set_bit(fd, MCP23008_IODIR, IO_GREEN, 0);
	set_bit(fd, MCP23008_IODIR, IO_YELLOW, 0);
	set_bit(fd, MCP23008_IODIR, IO_RED, 0);
	set_bit(fd, MCP23008_IODIR, IO_ADC, 0);
	set_bit(fd, MCP23008_IODIR, IO_BUTTON, 1);
	set_bit(fd, MCP23008_GPPU, IO_BUTTON, 1);

	if(green >= 0)
		set_val(fd, IO_GREEN, green);
	if(yellow >= 0)
		set_val(fd, IO_YELLOW, yellow);
	if(red >= 0)
		set_val(fd, IO_RED, red);
	if(adc >= 0)
		set_val(fd, IO_ADC, adc);
	if(aux >= 0) {
		set_val(fd, IO_AUX, aux);
		set_aux_dir(fd, 0);
	}
	if(pullup >= 0)
		set_aux_pu(fd, pullup);
	if(auxin > 0)
		set_aux_dir(fd, 1);

	printf("Green  = %d\n", get_val(fd, IO_GREEN));
	printf("Red    = %d\n", get_val(fd, IO_RED));
	printf("Yellow = %d\n", get_val(fd, IO_YELLOW));
	printf("ADC    = %d\n", get_val(fd, IO_ADC));
	printf("Button = %d\n", get_val(fd, IO_BUTTON));
	printf("Aux    = %d\n", get_val(fd, IO_AUX));

	close(fd);
	return 0;
}
