#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <fcntl.h>
#include <linux/input.h>

static const char *device = "/dev/event0";

static void print_usage(const char *prog)
{
	printf("Usage: %s [device]\n", prog);
	puts("  device        device to use (default /dev/event0)\n");
	exit(1);
}

static void parse_opts(int argc, char *argv[])
{
	while (1) {
		static const struct option lopts[] = {
			{ "help", 0, 0, 'h' },
			{ NULL, 0, 0, 0 },
		};
		int c;

		c = getopt_long(argc, argv, "h", lopts, NULL);

		if (c == -1)
			break;

		switch (c) {
		case 'h':
		default:
			print_usage(argv[0]);
			break;
		}
	}
}

int main(int argc, char *argv[])
{
	int ev;
	struct input_event event[1];

	parse_opts(argc, argv);

	device=argv[optind];

	ev = open(device, O_RDONLY);
	if (ev < 0) {
		printf("File not found!\n");
		exit(1);
	}

	printf("Watching for input on %s\n", device);
    
	while(1) {
		read(ev, event, sizeof(struct input_event));

		/* Only print key events */
		if (event->type == EV_KEY) {
			printf("Button %d %s\n",
				  event->code,
				  (event->value)?"pressed":"released"); 
		}
	}
}
