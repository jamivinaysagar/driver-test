/*
 * Test application for i.MX ADC controller
 */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/imx_adc.h>

static const char *device = "/dev/imx_adc";
static const double vref = 2.5;
static const double maxval = 4095.0; /* 2^12 - 1 */

/* This is the data structure used to configure the interface */
struct t_adc_convert_param conversion;

int main(void)
{
	int ret = 0;
	int fd, i;
	short result;

	/* Open the device */	
	fd = open(device, O_RDWR);
	if (fd < 0) {
		printf("can't open device");
		return 1;
	}

	/* Set up the channel */
	conversion.channel = GER_PURPOSE_ADC2;

	/* Kick off a conversion */
	ret = ioctl(fd, IMX_ADC_CONVERT, &conversion);
	if (ret < 0) {
		printf("Conversion failed (err=%d)\n", ret);
		return 1;
	}

	printf("Channel %d\n", conversion.channel);

	/* Print out all of the samples that were gathered (up to 16) */
	for(i = 0; i < 16; i++) {
		unsigned short result = conversion.result[i];

		/* Only print if it isn't 0 */
		if(result) {
			/* V = Vref * Result / (2^12 -1) */
			double volts = vref * (double) result / maxval; 
			printf("%.4fV (0x%x)\n", volts, conversion.result[i]);
		}
	}
	close(fd);

	return 0;
}
