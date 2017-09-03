#include <stdio.h>
#include <pthread.h>
#include <string.h>

#include <fcntl.h>
#include <time.h>


//#define BUFSIZE 10240
#define BUFSIZE 1024
#define BYTE_SENT 66
#define INIT_BYTE 65
#define THRU_COUNTER 1024*2

void *do_read() {
	char buf[BUFSIZE];
	size_t bytesread = 0;
	FILE * fp = open("/dev/upp", O_RDONLY);
	int count = THRU_COUNTER;
	while (fp) {
//		memset(buf,INIT_BYTE,BUFSIZE);
		buf[0]=INIT_BYTE;
		bytesread = read(fp, buf, BUFSIZE);
		if (bytesread < BUFSIZE)
			printf("less than BUFSIZE read\n");
		if (buf[0] != BYTE_SENT) {
			printf("byte read does not match sent byte. %d\n", buf[0]);
		}
		if (!count--) {
			printf("%d bytes xferred at %d seconds\n", BUFSIZE*THRU_COUNTER, time(0));
			count = THRU_COUNTER;
		}
	}
	close(fp);
}

void *do_write() {
	char buf[BUFSIZE];
	size_t written;
	FILE *fp = open("/dev/upp", O_WRONLY);
	memset(buf,BYTE_SENT,BUFSIZE);
	printf("waiting to 2s write\n");
	sleep(2);
	while (fp) {
		written = write(fp, buf, BUFSIZE);
	}
	close(fp);
}	

int main()
{
	pthread_t read_thread, write_thread;
   
	pthread_create( &read_thread, NULL, &do_read, NULL);
	pthread_create( &write_thread, NULL, &do_write, NULL);

	pthread_join( read_thread, NULL);
	pthread_join( write_thread, NULL);

	return 0;
}
