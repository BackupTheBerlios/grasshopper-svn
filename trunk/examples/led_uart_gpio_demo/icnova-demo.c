/*
 * This little program will do some basix work on a ICNova.
 * The current program-flow is the following:
 *	* print "Hello World" on the first two usarts
 *	* switch LED2 on
 *	* toggle LED3 some times.
 *	* switch LED2 off
 *	* read in the Status of GPIO-PORT B and print it out.
 *
 * (C) 2008 by Benjamin Tietz <benjamin.tietz@in-circuit.de>
 * licensed under the terms of the GPL.
 *
 */

#include "uart.h"
#include "gpio.h"
#include "led.h"
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAXSIZE 1024

int usart(int argc, char **argv) {
	int i, usart0, usart1;
	size_t len;
	char *buf;
	struct icnova_usart us_set = {
		.baudrate 	= 115200,
		.databits 	= 8,
		.stopbits 	= 1,
		.parity		= US_PAR_NONE,
		.flow_control	= US_CTL_NONE,
	};
	printf("printing on the USARTs: ");
	// First print Hello World.
	// If there was another Argument given on the command-line,
	// we will print that instead.
	if(argc>0) {
		buf = malloc(MAXSIZE);
		memset(buf,0,MAXSIZE);
		len = 0;
		for(i=0;i<argc && len<MAXSIZE;i++) {
			strncpy(buf+len - 1,argv[i],MAXSIZE-len);
			len = strlen(buf) + 1;
		}
		len--; // Just for the \0
	} else {
		buf = "Hello World";
		len = strlen(buf);
	}
	// Open the both usarts
	usart0 = init_usart(0,NULL); 	// Open without changing settings of the
					// serial line.
	if(usart0 <= 0) {
		printf("Can't open the serial line 0: %s\n",strerror(errno));
		return usart0;
	}
	usart1 = init_usart(1,&us_set); // Open and set the correct parameters.
	if(usart1 <= 0) {
		printf("Can't open the serial line 1: %s\n",strerror(errno));
		return usart1;
	}
	// Write the string out
	write(usart0,buf,len); write(usart0,"\n",1);
	write(usart1,buf,len); write(usart1,"\n",1);
	// Close the ports
	close(usart0);
	close(usart1);
	printf("done.\n");
	return 0;
}

int led(void) {
	int i;
	leddesc *led2, *led3;
	printf("Blinking the leds: ");
	// First open the LEDs
	led2 = init_led(2);
	if(led2==NULL) {
		printf("Can't open led2: %s\n",strerror(errno));
		return -1;
	}
	led3 = init_led(3);
	if(led3==NULL) {
		printf("Can't open led3: %s\n",strerror(errno));
		return -1;
	}
	// Now let the LEDs blink
	printf(".");
	set_led(led2, LED_ON);
	for(i=0;i<10;i++) {
		toggle_led(led3);
		sleep(1);
		printf(".");
		fflush(stdout);
	}
	set_led(led2,LED_OFF);
	printf(" done.\n");
	return 0;
}

int gpio(void) {
	int i, gpio;
	char buf[4];
	// First we must open the Port.
	// We want tu use the first 16 lines of Port D
	printf("Reading GPIO-Port: ");
	gpio = init_gpio("demo",'D',0x0000FFFFUL,O_RDONLY);
	if(gpio<0) {
		printf("Can't open GPIO-Port D: %s\n",strerror(errno));
		return gpio;
	}
	// Now we can use the default read/write calls
	// from the OS
	i = read(gpio,buf,4);
	if(i<0) {
		printf("Can't read from GPIO-Port: %s\n",strerror(errno));
		return i;
	}
	printf("done.\nStatus of Port D is 0x%02X%02X%02X%02X\n",
			buf[0],buf[1],buf[2],buf[3]);
	destroy_gpio("demo",gpio);
}
	
int main(int argc, char **argv) {
	int ret;
	ret = usart(argc-1,argv); //(+sizeof(char *));
	if(ret < 0) return ret;
	ret = led();
	if(ret < 0) return ret;
	ret = gpio();
	return ret;
}
