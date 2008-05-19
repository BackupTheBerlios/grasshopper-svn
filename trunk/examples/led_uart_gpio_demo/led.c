/*
 * This will implement the led-interface
 *
 * (C) 2008 by Benjamin Tietz <benjamin.tietz@in-circuit.de>
 */

#include "led.h"

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>

#define PATH "/sys/class/leds/led0:green/brightness"

leddesc *init_led(int led) {
	char *file = malloc(strlen(PATH));
	int i;
	leddesc *ret = malloc(sizeof(leddesc));

	strncpy(file,PATH,strlen(PATH));
	// find the correct file
	for(i=0;i<strlen(file);i++) {
		if(file[i] == '0')
			break;
	}
	*(file + i) = '0' + led;
	
	ret->name = file;
	return ret;
}

void set_led(leddesc *led, int brightness) {
	char val[5];
	int fh;
	sprintf(val,"%d\n",brightness & 0x00FF);
	fh = open(led->name,O_WRONLY);
	if(fh <= 0) {
		fprintf(stderr,"Can't open %s: %s\n",led->name,strerror(errno));
		return;
	}
	if(write(fh,val,strlen(val)) <= 0) {
		fprintf(stderr,"Couldn't write new value to %s: %s\n",led->name,
				strerror(errno));
	}
	close(fh);
}

int get_led(leddesc *led) {
	char buf[5];
	int fh;
	memset(buf,0,5);
	fh = open(led->name,O_RDONLY);
	if(fh<=0) {
		fprintf(stderr,"Can't open %s: %s\n",led->name,strerror(errno));
		return;
	}
	read(fh,buf,5);
	close(fh);
	sscanf(buf,"%02X",&fh);
	return fh;
}

