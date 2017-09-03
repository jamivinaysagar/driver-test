/*
 * Watchdog Driver Test Program
 *
 * [linux-kernel-dir]/Documentation/watchdog/watchdog-api.txt
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/watchdog.h>


/*
 * This function simply sends an IOCTL to the driver, which in turn ticks
 * the PC Watchdog card to reset its internal timer so it doesn't trigger
 * a computer reset.
 */
static void keep_alive(int fd)
{
    int dummy;

    ioctl(fd, WDIOC_KEEPALIVE, &dummy);
}

/*
 * The main program.
 *
 * Accepts no arguments.
 *
 * Tests setting the watchdog timer and
 * resetting it. It does not test whether
 * the timer actually resets the system;
 * this should be done manually, g.e. 'echo
 * a > /dev/watchdog'. Otherwise,
 * it will interrupt the rest of the test
 * suite. There is a chance that it may
 * interrupt the suite still due to the
 * possibility of not being able to stop
 * the timer. Thus, it should be recommended
 * that this test be ran last.
 *
 * Resetting the system with the Watchdog
 * timer should be done manually.
 */
int main(int argc, char *argv[])
{
    int flags, timer, settimeout_result, ioctl_result, fd;

    fd = open("/dev/watchdog", O_WRONLY);

    if (fd == -1) {
	fprintf(stderr, "Watchdog device not enabled.\n");
	fflush(stderr);
	exit(EXIT_FAILURE);
    }

    fprintf(stderr, "Watchdog card enabled.\n");
    fflush(stderr);

    timer = 10;

    /* Set the timeout and make sure that the watchdog
     * doesn't trigger early.
     *
     * NOTE: This will not work if CONFIG_WATCHDOG_NOWAYOUT is
     *       selected when compiling the kernel. Some drivers
     *       will force-select this option in Kconfig. */
    while (timer <= 30) {
	keep_alive(fd);
	sleep(1);

	settimeout_result = timer;
	ioctl_result = ioctl(fd, WDIOC_SETTIMEOUT, &settimeout_result);

	if (ioctl_result < 0) {
            fprintf(stderr, "SETTIMEOUT is returned the following error:\n");
	    perror("");
            break;
	}

	fprintf(stderr, "The timeout was set to %d seconds\n", settimeout_result);

	/* Give about a 5 second window to see if the timer
	 * resets early. */
	sleep(timer - 5);

	/* Increment the timer to try a larger time. */
	timer += 10;
    }

    flags = WDIOS_DISABLECARD;
    if (ioctl(fd, WDIOC_SETOPTIONS, &flags) == -1) {
	fprintf(stderr, "Disabling the watchdog timer after starting it "
			"is not supported with this driver. If it is working "
			"as intended, the system will reset.");

    } else {
        fprintf(stderr, "Watchdog card disabled.\n");
    }

    fflush(stderr);

    close(fd);

    /* Indicate to the user
     * that the test couldn't
     * run properly. */
    if (ioctl_result < 0) {
        exit(EXIT_FAILURE);
    }

    return 0;
}
