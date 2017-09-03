/*
 * uart-loopback.c - UART loopback test
 *
 * Copyright (C) 2012 Timesys Corporation
 *
 */

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/ioctl.h>

#define TIOCM_LOOP        0x8000

void print_usage(char *prg)
{
	printf("\nUsage: %s [OPTIONS] TTY\n\n", prg);
	printf("Options: -b <baud>   UART baud rate (default: 115200)\n");
	printf("         -c <count>  ascii count (default 127)\n");
	printf("         -t <time>   timeout (in seconds) (default 10 sec)\n");
	printf("         -d          hardware loopback\n");
	printf("         -h          show this help\n");
	printf("\nExample:\n");
	printf("         uart-loopback /dev/ttyS1\n");
	printf("\n");
	exit(1);
}


int enable_hw_loop(int fd)
{
	int status;

	ioctl(fd, TIOCMGET, &status);
	status |= TIOCM_LOOP;
	ioctl(fd, TIOCMSET, &status);

	/* Check to see if it took */	
	ioctl(fd, TIOCMGET, &status);

	return (status & TIOCM_LOOP)?1:0;

}

void disable_hw_loop(int fd)
{
	int status;

	ioctl(fd, TIOCMGET, &status);
	status &= ~TIOCM_LOOP;
	ioctl(fd, TIOCMSET, &status);
}

void cleanup(int fd, int status)
{
	disable_hw_loop(fd);
	close(fd);
	
	exit(status);
}

int set_baud_rate(int fd, int baud)
{
	struct termios termOptions;
	speed_t speed = B0;

	// Get the current options
	tcgetattr(fd, &termOptions);

	if (baud >= 230400) {
		speed = B230400;
		baud = 230400;
	} else if (baud >= 115200) {
		speed = B115200;
		baud = 115200;
	} else if (baud >= 57600) {
		speed = B57600;
		baud = 57600;
	} else if (baud >= 38400) {
		speed = B38400;
		baud = 38400;
	} else if (baud >= 19200) {
		speed = B19200;
		baud = 19200;
	} else if (baud >= 9600) {
		speed = B9600;
		baud = 9600;
	} else if (baud >= 4800) {
		speed = B4800;
		baud = 4800;
	} else if (baud >= 2400) {
		speed = B2400;
		baud = 2400;
	} else if (baud >= 1800) {
		speed = B1800;
		baud = 1800;
	} else if (baud >= 1200) {
		speed = B1200;
		baud = 1200;
	} else if (baud >= 600) {
		speed = B600;
		baud = 600;
	} else if (baud >= 300) {
		speed = B300;
		baud = 300;
	} else if (baud >= 200) {
		speed = B200;
		baud = 200;
	} else if (baud >= 150) {
		speed = B150;
		baud = 150;
	} else if (baud >= 134) {
		speed = B134;
		baud = 134;
	} else if (baud >= 110) {
		speed = B110;
		baud = 110;
	} else if (baud >= 75) {
		speed = B75;
		baud = 75;
	} else if (baud >= 50) {
		speed = B50;
		baud = 50;
	} else {
		speed = B0;
		baud = 0;
	}
	
	// Set the input/output speed to Baud Rate
	cfsetispeed(&termOptions, speed);
	cfsetospeed(&termOptions, speed);
 
	// Now set the term options (set immediately)
	tcsetattr(fd, TCSANOW, &termOptions);

	printf("Baud:\t\t%d\n",baud);

	return 0;
}

int main(int argc, char **argv)
{
	fd_set readfs;    /* file descriptor set */
	int fd,ret;
	char *tty;
	int baud = 115200;
	int count = 127;
	int timeout = 10;
	int hw_loop = 0;
	int opt;
	char i;

	while ((opt = getopt(argc, argv, "b:c:t:dh")) != -1) {
		switch (opt) {
		case 'b':
			baud = atoi(optarg);
			break;

		case 'c':
			count = atoi(optarg);
			break;

		case 'd':
			hw_loop = 1;
			break;

		case 't':
			timeout = atoi(optarg);
			break;

		case 'h':
		default:
			print_usage(argv[0]);
			break;
		}
	}
    
                                                                
	if (argc - optind != 1)
		print_usage(argv[0]);

	tty = argv[optind];

	printf("Port:\t\t%s\n",tty);
	printf("Count:\t\t%d\n",count);
	printf("Timeout:\t%d\n",timeout);

	if ((fd = open (tty, O_RDWR)) < 0) {
		perror(tty);
		exit(1);
	}

	set_baud_rate(fd, baud);

	/* Setup hardware loopback */
	if(hw_loop) {
		if(enable_hw_loop(fd))
			printf("Hardware Loopback Enabled\n");
		else
			hw_loop = 0;
	} else
		disable_hw_loop(fd);

	if(!hw_loop)
		printf("Hardware Loopback Disabled\n");

	tcflush(fd, TCIFLUSH);
 
	for (i = 0; i < count; i++) {
		/* Cycle amongst characters between 33 and 127 inclusive */
		char byte_out = (i % 95) + 33;
		char byte_in;
		struct timeval Timeout;

		ret = write(fd,&byte_out, 1);

		if (ret != 1) {
			printf("FATAL: Write error!\n");
			cleanup(fd,1);
		}

		FD_SET(fd, &readfs);  /* set testing source */

    		/* set timeout value within input loop */
		Timeout.tv_usec = 0;  /* milliseconds */
		Timeout.tv_sec  = timeout;  /* seconds */
		ret = select(fd + 1, &readfs, NULL, NULL, &Timeout);

		if (ret == 0){
			printf("FATAL: Read timeout error!\n");
			cleanup(fd, 1);
		} else {
			ret=read(fd, &byte_in, 1);
		}

		if (ret != 1) {
			printf("FATAL: Read error!\n");
			cleanup(fd, 1);
		}

		if (byte_out != byte_in) {
			printf("FATAL: Read data error: wrote 0x%x read 0x%x\n", byte_out, byte_in);
			cleanup(fd, 1);
		}

		printf("%c", byte_in);

	}

	printf("\nSuccess!\n");

	cleanup(fd,0);
}
