/*
 * An interface for easy use of the leds.
 *
 * (C) 2008 by Benjamin Tietz
 */
#ifndef __LED_H
#define __LED_H

struct leddesc_s {
	char *name;
};

typedef struct leddesc_s leddesc;
/*
 * This will open an LED, so we can use it.
 *
 * led is the number of the LED to use, numbered like in the schematic.
 */
leddesc *init_led(int led);

/*
 * switch the LED on and off
 */
#define LED_ON 255
#define LED_OFF 0
void set_led(leddesc *led, int brightness);

/*
 * get the current status of the led
 */
int get_led(leddesc *led);

/*
 * Toggle the led
 */
#define toggle_led(l) set_led(l, get_led(l)?LED_OFF:LED_ON)

#endif
